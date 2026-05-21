using UnityEngine;

public class CameraFollow : MonoBehaviour
{
    public Transform target;
    public Vector3 offset = new Vector3(0, 4, -10);
    public float smoothSpeed = 0.125f;

    [Header("Shake Settings")]
    public float shakeDuration = 0.2f;
    public float shakeMagnitude = 0.2f;
    private float currentShakeDuration = 0f;

    public void TriggerShake()
    {
        currentShakeDuration = shakeDuration;
    }

    void LateUpdate()
    {
        if (target != null)
        {
            // Position standard derrière le joueur
            Vector3 desiredPosition = target.position + offset;
            
            // On ne suit que la position Z (profondeur) et Y (hauteur)
            Vector3 smoothedPosition = Vector3.Lerp(transform.position, desiredPosition, smoothSpeed);
            
            // Application du tremblement si actif
            if (currentShakeDuration > 0)
            {
                smoothedPosition += Random.insideUnitSphere * shakeMagnitude;
                currentShakeDuration -= Time.deltaTime;
            }

            // On applique la position lissée et secouée
            transform.position = smoothedPosition;

            // On ne fait PAS de LookAt ici pour éviter que la caméra ne pivote 
            // et ne fasse tourner tout le décor ! Elle reste fixée vers l'avant.
        }
    }
}
