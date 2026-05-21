using UnityEngine;
using System.Collections.Generic;

public class FlutterManager : MonoBehaviour
{
    public PlayerController player;

    void Start()
    {
        Debug.Log("UNITY_DEBUG: FlutterManager démarré. Envoi de 'Ready' à Flutter.");
        SendToFlutter.Send("Ready");
    }

    // This method will be called from Flutter using:
    // sendToUnity("FlutterManager", "OnMessageFromFlutter", "Expert|2,5");
    public void OnMessageFromFlutter(string message)
    {
        Debug.Log("UNITY_DEBUG: Message received from Flutter: " + message);
        
        // 1. Gestion de la Pause, de la Reprise et de l'Arrêt
        if (message == "Pause")
        {
            Time.timeScale = 0f;
            Debug.Log("UNITY_DEBUG: Jeu mis en pause !");
            return;
        }
        if (message == "Resume")
        {
            Time.timeScale = 1f;
            Debug.Log("UNITY_DEBUG: Jeu repris !");
            return;
        }
        if (message == "Stop")
        {
            if (MathManager.Instance != null)
            {
                MathManager.Instance.StopGame();
            }
            return;
        }

        // 2. Format attendu : "Mode|Tables" (ex: "Expert|2,5")
        string[] parts = message.Split('|');
        if (parts.Length >= 2)
        {
            string modeStr = parts[0];
            string tablesStr = parts[1];

            // 1. Détermination du mode
            MathManager.GameMode mode = MathManager.GameMode.Discovery;
            if (modeStr == "Expert") mode = MathManager.GameMode.Expert;
            else if (modeStr == "Intermediate") mode = MathManager.GameMode.Intermediate;

            // 2. Détermination des tables
            string[] tableArray = tablesStr.Split(',');
            List<int> tables = new List<int>();
            foreach (string t in tableArray)
            {
                if (int.TryParse(t, out int result))
                {
                    tables.Add(result);
                }
            }

            // 3. Application des paramètres et lancement du jeu !
            if (MathManager.Instance != null)
            {
                MathManager.Instance.activeTables = tables;
                MathManager.Instance.StartGame(mode);
            }
        }
        else
        {
            Debug.LogWarning("UNITY_DEBUG: Format de message invalide. Attendu: 'Mode|Tables' (ex: 'Expert|2,5')");
        }
    }
}
