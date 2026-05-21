using UnityEngine;

public class Gate : MonoBehaviour
{
    public int lane; // 0: Gauche, 1: Milieu, 2: Droite
    public int myAnswer;
    public bool isCorrect;

    void OnTriggerEnter(Collider other)
    {
        // On verifie si c'est bien le joueur qui traverse la porte
        if (other.CompareTag("Player"))
        {
            // On déclenche le tremblement de caméra pour donner du "Juice" !
            CameraFollow cam = Camera.main.GetComponent<CameraFollow>();
            if (cam != null) cam.TriggerShake();

            // Lancer la vérification centralisée dans MathManager !
            MathManager.Instance.CheckAnswer(myAnswer);
            
            // On affiche la question suivante (celle des prochaines portes) !
            LevelManager.Instance.ShowQuestionForNextGate();
            
            // On détruit la porte après l'avoir passée pour libérer la voie
            Destroy(gameObject);
        }
    }
}
