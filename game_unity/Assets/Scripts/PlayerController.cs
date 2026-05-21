using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public float laneDistance = 3f;
    public float jumpForce = 7f;
    public float forwardSpeed = 5f;
    public float laneChangeSpeed = 10f;
    
    [Header("Juice Settings")]
    public float maxLeanAngle = 20f;
    public float leanSpeed = 10f;

    private int targetLane = 1; // 0: Gauche, 1: Milieu, 2: Droite
    private Rigidbody rb;
    private bool isGrounded;
    private Renderer cubeRenderer;

    // Variables pour la détection du Swipe
    private Vector2 startTouchPosition;
    private Vector2 endTouchPosition;
    private float minSwipeDistance = 50f;

    void Start()
    {
        // On récupère la vitesse si le jeu a déjà été lancé par Flutter (évite le cube immobile)
        if (MathManager.Instance != null && MathManager.Instance.isGameStarted)
        {
            MathManager.GameMode mode = MathManager.Instance.currentMode;
            if (mode == MathManager.GameMode.Discovery) forwardSpeed = 5f;
            else if (mode == MathManager.GameMode.Intermediate) forwardSpeed = 5f;
            else if (mode == MathManager.GameMode.Expert) forwardSpeed = 12f;
            
            Debug.Log("UNITY_DEBUG: Player Start. Vitesse récupérée depuis MathManager: " + forwardSpeed);
        }
        else
        {
            forwardSpeed = 0f; // On attend que le joueur choisisse un mode !
        }

        rb = GetComponent<Rigidbody>();
        
        // On s'assure que le tag est correct pour les collisions
        gameObject.tag = "Player";
        
        // Configuration de la traînée de lumière
        SetupTrail();

        cubeRenderer = GetComponent<Renderer>();
        UpdateColor(); // Couleur initiale
    }

    void SetupTrail()
    {
        // On ajoute le composant TrailRenderer par le code
        TrailRenderer trail = gameObject.GetComponent<TrailRenderer>();
        if (trail == null) trail = gameObject.AddComponent<TrailRenderer>();
        
        trail.time = 0.5f; // Durée de vie de la traînée
        trail.startWidth = 0.5f; // Largeur au départ
        trail.endWidth = 0.0f; // Largeur à la fin (s'affine)
        
        // Utilisation d'un shader simple par défaut
        trail.material = new Material(Shader.Find("Sprites/Default"));
        
        // Création d'un dégradé de couleur (du cyan vers le bleu transparent)
        Gradient gradient = new Gradient();
        gradient.SetKeys(
            new GradientColorKey[] { new GradientColorKey(Color.cyan, 0.0f), new GradientColorKey(Color.blue, 1.0f) },
            new GradientAlphaKey[] { new GradientAlphaKey(1.0f, 0.0f), new GradientAlphaKey(0.0f, 1.0f) }
        );
        trail.colorGradient = gradient;
    }

    void Update()
    {
        // Avancement automatique
        transform.Translate(Vector3.forward * forwardSpeed * Time.deltaTime);

        // Déplacement latéral fluide
        Vector3 targetPosition = new Vector3((targetLane - 1) * laneDistance, transform.position.y, transform.position.z);
        transform.position = Vector3.Lerp(transform.position, targetPosition, laneChangeSpeed * Time.deltaTime);

        // Effet de Penché (Juice)
        float xDiff = targetPosition.x - transform.position.x;
        float targetZRotation = -xDiff * maxLeanAngle;
        
        // Application de la rotation fluide
        Quaternion targetRot = Quaternion.Euler(0, 0, targetZRotation);
        transform.rotation = Quaternion.Lerp(transform.rotation, targetRot, Time.deltaTime * leanSpeed);

        // Détection des contrôles tactiles
        DetectSwipe();
        
        // Détection des contrôles au clavier (pour le test sur PC)
        DetectKeyboard();
    }

    private void DetectKeyboard()
    {
        if (Input.GetKeyDown(KeyCode.LeftArrow))
        {
            MoveLeft();
        }
        else if (Input.GetKeyDown(KeyCode.RightArrow))
        {
            MoveRight();
        }
        else if (Input.GetKeyDown(KeyCode.Space) || Input.GetKeyDown(KeyCode.UpArrow))
        {
            Jump();
        }
    }

    private void DetectSwipe()
    {
#if UNITY_EDITOR
        // Contrôles à la souris pour l'éditeur PC
        if (Input.GetMouseButtonDown(0))
        {
            startTouchPosition = Input.mousePosition;
        }
        else if (Input.GetMouseButtonUp(0))
        {
            endTouchPosition = Input.mousePosition;
            AnalyzeSwipe();
        }
#else
        // Contrôles tactiles pour le téléphone
        if (Input.touchCount > 0)
        {
            Touch touch = Input.GetTouch(0);

            if (touch.phase == TouchPhase.Began)
            {
                startTouchPosition = touch.position;
            }
            else if (touch.phase == TouchPhase.Ended)
            {
                endTouchPosition = touch.position;
                AnalyzeSwipe();
            }
        }
#endif
    }

    private void AnalyzeSwipe()
    {
        float xDiff = endTouchPosition.x - startTouchPosition.x;
        float yDiff = endTouchPosition.y - startTouchPosition.y;

        if (Mathf.Abs(xDiff) > minSwipeDistance || Mathf.Abs(yDiff) > minSwipeDistance)
        {
            if (Mathf.Abs(xDiff) > Mathf.Abs(yDiff))
            {
                if (xDiff > 0)
                    MoveRight();
                else
                    MoveLeft();
            }
            else
            {
                if (yDiff > 0)
                    Jump();
            }
        }
    }

    public void MoveLeft()
    {
        if (targetLane > 0)
        {
            targetLane--;
            UpdateColor();
        }
    }

    public void MoveRight()
    {
        if (targetLane < 2)
        {
            targetLane++;
            UpdateColor();
        }
    }

    public void Jump()
    {
        if (isGrounded)
        {
            rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
            isGrounded = false;
        }
    }

    private void UpdateColor()
    {
        if (cubeRenderer != null)
        {
            switch (targetLane)
            {
                case 0:
                    cubeRenderer.material.color = Color.blue;
                    break;
                case 1:
                    cubeRenderer.material.color = Color.green;
                    break;
                case 2:
                    cubeRenderer.material.color = Color.red;
                    break;
            }
        }
    }

    void OnCollisionStay(Collision collision)
    {
        isGrounded = true;
    }

    void OnCollisionExit(Collision collision)
    {
        isGrounded = false;
    }
}
