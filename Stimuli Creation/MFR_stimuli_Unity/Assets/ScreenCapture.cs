using UnityEngine;
using System.IO;

public class ScreenCapture : MonoBehaviour
{
    public int captureWidth = 1920;
    public int captureHeight = 1080;
    public string folder = "";

    private Rect rect;
    private RenderTexture renderTexture;
    private Texture2D screenShot;
    private int counter = 0;

    void Start()
    {
        if (string.IsNullOrEmpty(folder))
        {
            folder = Application.dataPath + "/Screenshots";
        }
        Directory.CreateDirectory(folder);
        rect = new Rect(0, 0, captureWidth, captureHeight);
    }

    void LateUpdate()
    {
        if (Input.GetKeyDown(KeyCode.F9))
        {
            CapturePNG();
        }
    }

    void CapturePNG()
    {
        if (renderTexture == null)
        {
            renderTexture = new RenderTexture(captureWidth, captureHeight, 24);
        }

        Camera cam = GetComponent<Camera>();
        cam.targetTexture = renderTexture;
        cam.Render();

        RenderTexture.active = renderTexture;

        if (screenShot == null)
        {
            screenShot = new Texture2D(captureWidth, captureHeight, TextureFormat.RGB24, false);
        }

        screenShot.ReadPixels(rect, 0, 0);
        screenShot.Apply();

        cam.targetTexture = null;
        RenderTexture.active = null;

        // Encode texture into PNG
        byte[] bytes = screenShot.EncodeToPNG();

        // Save PNG file
        string filename = string.Format("{0}/screenshot_{1:0000}.png", folder, counter++);
        File.WriteAllBytes(filename, bytes);

        Debug.Log("Saved PNG screenshot to: " + filename);
    }
}