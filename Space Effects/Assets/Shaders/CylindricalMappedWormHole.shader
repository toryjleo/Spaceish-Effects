
Shader "Custom/CylindricalMappedWormHole" {

	Properties
	{
		_Tex("Texture", 2D) = "white" {}

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
		sampler2D _Tex;

		// Methods
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
			float pi = 3.14;

			// Calculate distance from center (not actually normalized)
			float2 normalizedCoords = i.screenPos.xy - .5f;//i.vertex.xy / _ScreenParams.xy;


			// angle of each pixel to the center of the screen
			float angle = atan(normalizedCoords);

			// cylindrical tunnel
			float radius = length(normalizedCoords);

			// index texture by (animated inverse) radius and angle
			float2 uv = float2(0.3 / radius + 0.2 * _Time.y, angle / pi);

			// Get the rgb value from the _MainTex
			half4 col = tex2D(_Tex, uv);

			return col * radius;
		}
			ENDCG
		}
		}
}