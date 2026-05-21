using UnityEngine;
using System.Collections.Generic;
using TMPro;

public class LevelManager : MonoBehaviour
{
    public static LevelManager Instance;

    public Transform player;
    public float spawnDistance = 50f;
    public float spaceBetweenGates = 40f;
    private float nextSpawnZ;

    private List<GameObject> activeGates = new List<GameObject>();

    void Awake()
    {
        if (Instance == null) Instance = this;
    }

    void Start()
    {
        if (player == null)
        {
            player = GameObject.FindWithTag("Player").transform;
        }
        
        nextSpawnZ = 20f; // On commence plus près !
    }

    void Update()
    {
        // Si le jeu n'est pas commencé, on ne fait rien !
        if (MathManager.Instance == null || !MathManager.Instance.isGameStarted) return;

        if (player != null && player.position.z + spawnDistance > nextSpawnZ)
        {
            SpawnGateGroup();
            nextSpawnZ += spaceBetweenGates;
        }

        CleanupGates();
    }

    void SpawnGateGroup()
    {
        // On demande à MathManager de générer une nouvelle question
        MathManager.Instance.GenerateNewQuestion();
        
        string currentQuestion = MathManager.Instance.GetQuestionText();
        
        // Si c'est le tout premier groupe de portes, on affiche la question tout de suite !
        if (activeGates.Count == 0)
        {
            MathManager.Instance.UpdateQuestionText(currentQuestion);
        }

        // On crée un conteneur pour le groupe de portes
        GameObject groupObj = new GameObject("GateGroup_" + nextSpawnZ);
        groupObj.transform.position = new Vector3(0, 0, nextSpawnZ); // On lui donne la bonne position Z !
        
        // On crée les 3 portes
        for (int i = 0; i < 3; i++)
        {
            CreateGate(i, nextSpawnZ, currentQuestion, groupObj.transform);
        }
        
        // On ajoute un script pour stocker la question sur le groupe
        GateGroup groupScript = groupObj.AddComponent<GateGroup>();
        groupScript.question = currentQuestion;
        
        activeGates.Add(groupObj);
    }

    void CreateGate(int lane, float zPos, string question, Transform parent)
    {
        GameObject gate = GameObject.CreatePrimitive(PrimitiveType.Cube);
        gate.transform.parent = parent;
        
        float xPos = (lane - 1) * 3f; 
        gate.transform.position = new Vector3(xPos, 1f, zPos);
        gate.transform.localScale = new Vector3(2f, 2f, 0.2f);
        
        Renderer renderer = gate.GetComponent<Renderer>();
        renderer.material.color = new Color(1, 1, 1, 0.3f);
        
        gate.GetComponent<Collider>().isTrigger = true;
        
        // Config du script Gate
        Gate gateScript = gate.AddComponent<Gate>();
        gateScript.lane = lane;
        
        int answer = MathManager.Instance.GetAnswerForLane(lane);
        gateScript.myAnswer = answer;
        
        // Est-ce la bonne réponse ?
        gateScript.isCorrect = (answer == MathManager.Instance.GetCorrectAnswer());
        
        // Ajouter le texte 3D au-dessus
        GameObject textObj = new GameObject("Text");
        textObj.transform.parent = gate.transform;
        textObj.transform.localPosition = new Vector3(0, 1.5f, 0);
        
        TextMeshPro tmp = textObj.AddComponent<TextMeshPro>();
        tmp.alignment = TextAlignmentOptions.Center;
        tmp.fontSize = 10;
        tmp.color = Color.black;
        tmp.text = answer.ToString();
    }

    void CleanupGates()
    {
        if (activeGates.Count > 0 && activeGates[0].transform.position.z < player.position.z - 8f)
        {
            Destroy(activeGates[0]);
            activeGates.RemoveAt(0);
        }
    }

    public void ShowQuestionForNextGate()
    {
        // activeGates[0] est la porte que le joueur vient de passer.
        // Donc la SUIVANTE est à l'index 1 dans la liste !
        if (activeGates.Count > 1)
        {
            GateGroup group = activeGates[1].GetComponent<GateGroup>();
            if (group != null)
            {
                MathManager.Instance.UpdateQuestionText(group.question);
            }
        }
    }

    // Nouvelle fonction pour ajouter un délai !
    public void ShowQuestionForNextGateWithDelay(float delay)
    {
        StartCoroutine(ShowQuestionCoroutine(delay));
    }

    private System.Collections.IEnumerator ShowQuestionCoroutine(float delay)
    {
        yield return new WaitForSeconds(delay);
        ShowQuestionForNextGate();
    }

    public void ResetLevel(float initialDistance)
    {
        nextSpawnZ = initialDistance; // On adapte la distance de départ !
        foreach (GameObject gate in activeGates)
        {
            Destroy(gate); // On détruit toutes les portes
        }
        activeGates.Clear(); // On vide la liste
    }
}

// Petit script auxiliaire pour stocker la question sur le groupe de portes
public class GateGroup : MonoBehaviour
{
    public string question;
}
