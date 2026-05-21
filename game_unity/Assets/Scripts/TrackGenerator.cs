using UnityEngine;

public class TrackGenerator : MonoBehaviour
{
    public float laneDistance = 3f;
    public float trackLength = 200f;

    void Start()
    {
        CreateTrackLines();
    }

    void CreateTrackLines()
    {
        // Ligne de séparation Gauche/Milieu
        CreateLine(-laneDistance / 2f);
        
        // Ligne de séparation Milieu/Droite
        CreateLine(laneDistance / 2f);
    }

    void CreateLine(float xOffset)
    {
        // On crée un cube qu'on va étirer pour en faire une ligne
        GameObject line = GameObject.CreatePrimitive(PrimitiveType.Cube);
        
        // Positionnement (un tout petit peu au-dessus du sol pour éviter les bugs d'affichage)
        line.transform.position = new Vector3(xOffset, 0.02f, trackLength / 2f);
        
        // On l'étire pour en faire une longue ligne blanche
        line.transform.localScale = new Vector3(0.1f, 0.01f, trackLength);
        
        // On retire le collider pour que le joueur ne trébuche pas dessus !
        Destroy(line.GetComponent<Collider>());
        
        // On lui donne une couleur blanche bien visible
        line.GetComponent<Renderer>().material.color = Color.white;
        
        // On l'attache à ce générateur pour garder la hiérarchie propre
        line.transform.parent = this.transform;
    }
}
