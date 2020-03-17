using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraPostProcessing : MonoBehaviour
{
	public Material materialWithShader;
	public bool usePostProcess = true;

	void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if (usePostProcess)
		{
			Graphics.Blit(source, destination, materialWithShader);
		}
		else
		{
			Graphics.Blit(source, destination);
		}
	}
}
