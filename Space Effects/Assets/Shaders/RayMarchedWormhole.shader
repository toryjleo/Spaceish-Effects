Shader "Custom/RayMarchedWormhole"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Tex("Texture", 2D) = "white" {}
		_VignetteRadius("VignetteRadius", Float) = .8
		_VignetteSoftness("VignetteSoftness", Float) = .25
		_VertsColor("VertsColor", Range(0, 1)) = .7
		_Br("Brightness", Range(-50, 100)) = 60
		_Contrast("Contrast", Range(-5, 15)) = -1
	}
		SubShader
		{
			// No culling or depth
			Cull Off ZWrite Off ZTest Always

			Pass
		{
			CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag

	#include "UnityCG.cginc"

			struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
			float4 screenPos : TEXCOORD1;
		};


		// Uniforms

		sampler2D _MainTex;
		sampler2D _Tex;
		float _VignetteRadius;
		float _VignetteSoftness;
		float _VertsColor;
		float _Br;
		float _Contrast;

		// Constants
		static const float PI = 3.14159265f;

		// Methods

		// Still trying to figure this out (ish)
		float map(float l)
		{
			float lm = 1.0;
			//l = clamp(1e-1, l, l); // 
			float lm2 = lm * lm; // 1.0
			float lm4 = lm2 * lm2; // 1.0
			//return sqrt(lm4 / (l * l)); //+ lm2); // square root of (1 / (l^2) + 1)
			return sqrt(1/(l*l) + 20);
			// return 1.0/(l+1e-5);
		}

		float2 Rot(float2 v, float angle)
		{
			return float2(v.x * cos(angle) + v.y * sin(angle),
				v.y * cos(angle) - v.x * sin(angle));
		}

		float3 DrawCloud(float mappedLen, float angle, float2 coord)
		{
			float iTime = _Time.y ;
			float3 baseColor = float3(0.0, 0.0, 0.0);
			float3 cloudColor = float3(0.0, 0.3, 0.7);
			float x = angle + mappedLen;  // some strange combination of angle and distance
			float fre = 2.0;
			float ap = 1.0;
			float d = 0.0;  // d is a float percentage
			// Add rotation
			coord = Rot(coord, 0.3 * iTime); // adds waviness
			float3 kp = float3(coord, mappedLen);
			// Changes "d" every iteration
			for (int i = 1; i < 5; i++) {  // might want to fuck around with iteration number
				//float k = 1.0+ sin(fre * x + 0.3 * iTime);
				//k = k * k * 0.25f;
				float p = frac(mappedLen / (i + 1));//frac(k + mappedLen / float(i + 1)); // Gets decimal of k + distance from center of screen / (iteration + 1), gets more reduced every iteration. 'i' also introduces offset
				p = p * (1.0 - p);
				p = smoothstep(0.1, 0.25, p) * sin(iTime); // hermite interpolation
				d += ap * p;
				kp += sin(kp.zxy * 0.75 * fre + 0.3 * iTime ); // adds outward moving wavy lines and more circles
				d -= abs(dot(cos(kp), sin(kp.yzx)) * ap);  // Makes d darker
				fre *= -3.0; // decreasing this adds more waviness
				ap *= 0.5;  // every single iteration the ap modifier gets weaker
			}
			float len2 = dot(coord, coord);
			//d += len2 * 4.0;
			// D linearly scales rgb of the "cloud color"
			return baseColor + cloudColor * d; // consider making "d" alpha
		}

		/*
		coord - normalized coordinates with the center of the screen being the origin
		*/
		float3 Render(float2 coord)
		{
			float len = length(coord); // len is the distance from the center of the screen (0 to 1)
			// arccos goes to 0 if x goes to 1. 
			float angle = PI - acos(coord.x / len) * sign(coord.y); // 3.14 - angle(inradians) below x-axis * pos/neg sign of y-axis

			float3 baseColor = float3(0.0, 0.0, 0.0);
			float mappedLen = map(len);
			//return float3(dis / 50, dis / 50, dis / 50);;
			baseColor += DrawCloud(mappedLen, angle, coord) * 0.3;
			float3 fogColor = float3(0.3, 1.5, 3.0);
			float fogC = pow(0.97, mappedLen);
			baseColor = lerp(fogColor, baseColor, fogC); // might want to change how colors are added/interpolated
			return baseColor;
		}

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.screenPos = ComputeScreenPos(o.vertex);
			o.uv = v.uv;
			return o;
		}


		half4 frag(v2f i) : SV_Target
		{

		// Calculate distance from center (not actually normalized)
		float2 normalizedCoords = i.screenPos.xy;


		float2 coord = normalizedCoords.xy - 0.5;
		if (_ScreenParams.y > _ScreenParams.x) {
			coord.x *= _ScreenParams.x / _ScreenParams.y;
		}
		else {
			coord.y /= _ScreenParams.x / _ScreenParams.y;
		}
		float3 baseColor = Render(coord);
		float4 fragColor = float4(baseColor * 1.3, 1.0);

		return fragColor;
	}
		ENDCG
	}
	}
}
