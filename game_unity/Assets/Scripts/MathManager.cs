using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI; // Pour créer le flash rouge !
using TMPro;

public class MathManager : MonoBehaviour
{
    public static MathManager Instance;

    public TextMeshProUGUI questionText; // Référence vers le texte de l'opération
    public TextMeshProUGUI scoreText;    // Référence vers le texte du score
    public TextMeshProUGUI livesText;    // Référence vers le texte des vies
    public GameObject menuPanel; // Le conteneur des boutons !
    
    private int num1;
    private int num2;
    private int correctAnswer;
    private List<int> answers = new List<int>();
    private List<int> validMultiplicationResults = new List<int>();
    
    // Les tables que l'apprenant doit travailler (envoyé par Flutter)
    public List<int> activeTables = new List<int>() { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    
    // La pioche de cartes (les questions restantes)
    private List<Vector2Int> questionPool = new List<Vector2Int>();

    // Pour éviter la répétition des voies
    private int lastCorrectLane = -1;
    private int sameLaneCount = 0;

    [Header("Game State")]
    public int score = 0;
    public int lives = 3;
    private bool isGameOver = false;
    private float questionStartTime;
    public bool isGameStarted = false; // Le jeu a-t-自 commencé ?

    public enum GameMode { Discovery, Intermediate, Expert }
    public GameMode currentMode = GameMode.Discovery;

    void Awake()
    {
        if (Instance == null) Instance = this;
        else Destroy(gameObject);

        GenerateValidResults();
    }

    void GenerateValidResults()
    {
        // On génère tous les résultats possibles des tables de 1 à 10
        for (int i = 1; i <= 10; i++)
        {
            for (int j = 1; j <= 10; j++)
            {
                if (!validMultiplicationResults.Contains(i * j))
                {
                    validMultiplicationResults.Add(i * j);
                }
            }
        }
        validMultiplicationResults.Sort(); // On trie pour que le mode expert fonctionne bien !
    }

    void GenerateQuestionPool()
    {
        questionPool.Clear();
        // Pour chaque table active, on ajoute les 10 multiplications possibles
        foreach (int table in activeTables)
        {
            for (int i = 1; i <= 10; i++)
            {
                questionPool.Add(new Vector2Int(table, i));
            }
        }
        ShuffleQuestionPool(); // On mélange le paquet !
        Debug.Log($"Paquet de cartes généré avec {questionPool.Count} questions.");
    }

    void ShuffleQuestionPool()
    {
        for (int i = 0; i < questionPool.Count; i++)
        {
            Vector2Int temp = questionPool[i];
            int randomIndex = Random.Range(i, questionPool.Count);
            questionPool[i] = questionPool[randomIndex];
            questionPool[randomIndex] = temp;
        }
    }

    void Start()
    {
        // On ne lance pas la question tout de suite, on attendra le choix du menu
        // GenerateNewQuestion(); 
        
        // On cache les textes de gameplay au début !
        if (scoreText != null) scoreText.gameObject.SetActive(false);
        if (livesText != null) livesText.gameObject.SetActive(false);
        if (questionText != null) questionText.gameObject.SetActive(false);

        // Gestion du menu selon la plateforme
#if UNITY_EDITOR
        // Dans l'éditeur Unity, on laisse le menu visible pour pouvoir tester !
        if (menuPanel != null) menuPanel.SetActive(true);
#else
        // Sur le téléphone (dans Flutter), on le cache pour éviter le flash visuel !
        if (menuPanel != null) menuPanel.SetActive(false);
#endif
    }

    public void StartGame(GameMode mode)
    {
        currentMode = mode;
        isGameOver = false;
        isGameStarted = true; // C'est parti !
        score = 0;
        
        // On règle les vies selon le mode (toujours !)
        if (mode == GameMode.Discovery) lives = 5;
        else if (mode == GameMode.Intermediate) lives = 3;
        else if (mode == GameMode.Expert) lives = 3; // Passé de 1 à 3 pour les tests !
        
        // On calcule la distance de départ selon le mode
        float startDistance = 20f;
        if (mode == GameMode.Expert) startDistance = 50f;
        
        // On réinitialise le niveau (portes) avec la bonne distance
        if (LevelManager.Instance != null) LevelManager.Instance.ResetLevel(startDistance);
        
        // On cache le menu !
        if (menuPanel != null)
        {
            menuPanel.SetActive(false);
        }
        
        // SOLUTION RADICALE : On cherche TOUS les boutons de la scène et on les cache !
        Button[] allButtons = FindObjectsByType<Button>(FindObjectsSortMode.None);
        foreach (Button b in allButtons)
        {
            b.gameObject.SetActive(false);
        }
        
        PlayerController player = FindFirstObjectByType<PlayerController>();
        if (player != null)
        {
            // On remet le joueur au début
            player.transform.position = new Vector3(0, player.transform.position.y, 0);
            
            if (mode == GameMode.Discovery) player.forwardSpeed = 5f;
            else if (mode == GameMode.Intermediate) player.forwardSpeed = 5f;
            else if (mode == GameMode.Expert) player.forwardSpeed = 20f; // Vitesse augmentée à 20 !
        }

        GenerateQuestionPool(); // On prépare le paquet de cartes !
        GenerateNewQuestion();
        
        // On affiche les textes de gameplay EN DERNIER pour éviter le "flash" des textes par défaut !
        if (scoreText != null) scoreText.gameObject.SetActive(true);
        if (livesText != null) livesText.gameObject.SetActive(true);
        if (questionText != null) questionText.gameObject.SetActive(true);
    }

    // Fonctions simples pour les boutons Unity UI
    public void StartDiscovery() { StartGame(GameMode.Discovery); }
    public void StartIntermediate() { StartGame(GameMode.Intermediate); }
    public void StartExpert() { StartGame(GameMode.Expert); }

    public void GenerateNewQuestion()
    {
        if (isGameOver) return;

        questionStartTime = Time.time;

        // Si le paquet est vide, on en régénère un nouveau !
        if (questionPool.Count == 0)
        {
            GenerateQuestionPool();
        }

        // On tire la première carte du paquet (qui est mélangé)
        Vector2Int question = questionPool[0];
        num1 = question.x;
        num2 = question.y;
        correctAnswer = num1 * num2;
        
        // On retire cette carte du paquet pour ne pas retomber dessus !
        questionPool.RemoveAt(0);

        // Création de la liste des réponses
        answers.Clear();
        answers.Add(correctAnswer);

        // Ajout de deux fausses réponses
        while (answers.Count < 3)
        {
            int wrongAnswer = 0;
            
            if (currentMode == GameMode.Expert)
            {
                // Mode Expert : on cherche un résultat "crédible" proche dans la liste
                int index = validMultiplicationResults.IndexOf(correctAnswer);
                int offset = Random.Range(-3, 4); // Entre -3 et +3
                if (offset == 0) offset = 1; // Éviter de reprendre la même
                
                int targetIndex = Mathf.Clamp(index + offset, 0, validMultiplicationResults.Count - 1);
                wrongAnswer = validMultiplicationResults[targetIndex];
            }
            else
            {
                // Mode Normal : on pioche n'importe quel vrai résultat au hasard
                wrongAnswer = validMultiplicationResults[Random.Range(0, validMultiplicationResults.Count)];
            }

            // On vérifie que ce n'est pas déjà dans la liste et que ce n'est pas la bonne réponse
            if (!answers.Contains(wrongAnswer) && wrongAnswer != correctAnswer)
            {
                answers.Add(wrongAnswer);
            }
        }

        // Mélange des réponses
        ShuffleList(answers);

        // Vérification anti-répétition (max 2 fois de suite)
        int currentCorrectLane = answers.IndexOf(correctAnswer);
        if (currentCorrectLane == lastCorrectLane)
        {
            sameLaneCount++;
            if (sameLaneCount >= 3)
            {
                // Si c'est la 3ème fois, on remélange jusqu'à ce que ce soit une autre voie !
                while (currentCorrectLane == lastCorrectLane)
                {
                    ShuffleList(answers);
                    currentCorrectLane = answers.IndexOf(correctAnswer);
                }
                sameLaneCount = 1; // On remet le compteur à 1 pour la nouvelle voie
            }
        }
        else
        {
            sameLaneCount = 1;
            lastCorrectLane = currentCorrectLane;
        }
    }

    void UpdateUI()
    {
        if (questionText != null)
        {
            if (isGameOver)
            {
                questionText.gameObject.SetActive(false); // On cache le texte, Flutter s'en occupe !
            }
            else
            {
                questionText.text = $"{num1} x {num2} = ?";
                questionText.color = Color.yellow; // On remet en jaune !
            }
        }

        if (scoreText != null) scoreText.text = $"Score: {score}";
        if (livesText != null) livesText.text = $"Vies: {lives}";
    }

    // Nouvelle fonction pour mettre à jour le texte depuis l'extérieur
    public void UpdateQuestionText(string customQuestion)
    {
        if (questionText != null && !isGameOver)
        {
            questionText.text = customQuestion;
        }
        if (scoreText != null) scoreText.text = $"Score: {score}";
        if (livesText != null) livesText.text = $"Vies: {lives}";
    }

    // Petite méthode pour mélanger la liste
    private void ShuffleList(List<int> list)
    {
        for (int i = 0; i < list.Count; i++)
        {
            int temp = list[i];
            int randomIndex = Random.Range(i, list.Count);
            list[i] = list[randomIndex];
            list[randomIndex] = temp;
        }
    }

    public bool CheckAnswer(int selectedAnswer)
    {
        if (isGameOver) return false;

        float duration = Time.time - questionStartTime;
        bool success = (selectedAnswer == correctAnswer);
        
        // On prévient Flutter du résultat pour les statistiques pédagogiques avec la durée
        SendToFlutter.Send($"AnsweredStatement|{num1}|{num2}|{success}|{duration.ToString("F2")}");

        if (success)
        {
            Debug.Log("JUSTE ! Bravo !");
            AddScore(10); // Utiliser AddScore pour rafraîchir l'UI et accélérer
            GenerateNewQuestion(); // On passe à la suivante
            return true;
        }
        else
        {
            Debug.Log("FAUX ! Perte de vie.");
            lives--; // -1 vie
            UpdateUI(); // On met à jour l'affichage des vies !
            StartCoroutine(FlashUIText()); // Effet de flash sur le texte !
            StartCoroutine(FlashScreenRed()); // Flash rouge sur tout l'écran !
            
            if (lives <= 0)
            {
                isGameOver = true;
                UpdateUI();
                Debug.Log("GAME OVER!");
                
                // On affiche à nouveau le menu pour rejouer (uniquement dans l'éditeur) !
#if UNITY_EDITOR
                if (menuPanel != null) menuPanel.SetActive(true);
#endif
                // On prévient Flutter que la partie est finie avec le score !
                SendToFlutter.Send($"GameOver|{score}");
                
                // On arrête le joueur
                PlayerController player = FindFirstObjectByType<PlayerController>();
                if (player != null) player.forwardSpeed = 0;
            }
            else
            {
                GenerateNewQuestion(); // On passe à la suivante quand même
            }
            return false;
        }
    }

    // Getters pour que les portes puissent lire les valeurs
    public string GetQuestionText()
    {
        return $"{num1} x {num2} = ?";
    }

    public int GetAnswerForLane(int lane)
    {
        if (lane >= 0 && lane < answers.Count)
            return answers[lane];
        return 0;
    }

    public int GetCorrectAnswer()
    {
        return correctAnswer;
    }

    public void AddScore(int points)
    {
        score += points;
        
        // Si on est en mode Intermédiaire, on accélère le joueur !
        if (currentMode == GameMode.Intermediate)
        {
            PlayerController player = FindFirstObjectByType<PlayerController>();
            if (player != null)
            {
                player.forwardSpeed += 0.2f; // +0.2 à chaque bonne réponse
                Debug.Log($"Vitesse augmentée : {player.forwardSpeed}");
            }
        }
        
        UpdateUI(); // On rafraîchit l'affichage TOUT DE SUITE !
    }

    private IEnumerator FlashUIText()
    {
        questionText.color = Color.red;
        float originalSize = questionText.fontSize;
        questionText.fontSize = originalSize * 1.2f; // Grossit de 20%
        
        yield return new WaitForSeconds(0.2f); // Pendant 0.2 secondes
        
        questionText.color = Color.yellow;
        questionText.fontSize = originalSize; // Revient à la normale
    }

    private IEnumerator FlashScreenRed()
    {
        // On cherche le canvas parent du texte
        Canvas canvas = questionText.GetComponentInParent<Canvas>();
        if (canvas != null)
        {
            // Création d'un objet Image plein écran
            GameObject flashObj = new GameObject("RedFlash");
            flashObj.transform.SetParent(canvas.transform, false);
            
            Image img = flashObj.AddComponent<Image>();
            img.color = new Color(1f, 0f, 0f, 0.4f); // Rouge à 40% de transparence
            
            // On étire l'image sur tout l'écran
            RectTransform rect = img.rectTransform;
            rect.anchorMin = Vector2.zero;
            rect.anchorMax = Vector2.one;
            rect.offsetMin = Vector2.zero;
            rect.offsetMax = Vector2.one;
            
            yield return new WaitForSeconds(0.15f); // Pendant 0.15 secondes
            
            Destroy(flashObj); // On supprime l'image
        }
    }

    public void StopGame()
    {
        isGameOver = true;
        PlayerController player = FindFirstObjectByType<PlayerController>();
        if (player != null) player.forwardSpeed = 0f;

        if (scoreText != null) scoreText.gameObject.SetActive(false);
        if (livesText != null) livesText.gameObject.SetActive(false);
        if (questionText != null) questionText.gameObject.SetActive(false);
    }

    // Appelé par Flutter au lancement
    public void ChangeCar(string unityId)
    {
        Debug.Log("Changement de voiture : " + unityId);
        GameObject car = GameObject.FindGameObjectWithTag("Player");
        if (car != null)
        {
            Renderer renderer = car.GetComponentInChildren<Renderer>();
            if (renderer != null)
            {
                if (unityId == "car_red") renderer.material.color = Color.red;
                else if (unityId == "car_blue") renderer.material.color = Color.blue;
                else if (unityId == "car_green") renderer.material.color = Color.green;
                else if (unityId == "car_yellow") renderer.material.color = Color.yellow;
            }
        }
    }
}
