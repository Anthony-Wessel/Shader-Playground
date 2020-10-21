Shader "Unlit/FireShader"
{
    Properties
    {
        _NoiseTex ("Texture", 2D) = "white" {}
		
		_BaseColor("Base Color", Color) = (0,0,0,0)
		_TipColor("Tip Color", Color) = (0,0,0,0)
		_SmokeColor("Smoke Color", Color) = (0,0,0,0)
    }
    SubShader
    {
        Tags
		{
			"Queue" = "Overlay"
			"IgnoreProjector" = "True"
			"RenderType" = "Opaque"
		}

        Pass
        {
			Lighting Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

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
				float4 localPos : TEXCOORD2;
            };

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

			fixed4 _BaseColor;
			fixed4 _TipColor;
			fixed4 _SmokeColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.localPos = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col;
				// scroll the uv coords
				float2 uv = i.uv - float2(0, _Time.x*4);

				// grab noise at 2 different scales
				fixed4 noise = tex2D(_NoiseTex, uv*8);
				fixed4 noise2 = tex2D(_NoiseTex, uv);

				// combine the 2 pieces of noise
				noise = noise * 0.75 + noise2 * 0.25;

				// grab the y position and force it mostly positive
				float adjustedY = i.localPos.y + 0.45;

				// Lerp between 2 shades for the main fire color
				col = lerp(_BaseColor, _TipColor, noise.x - adjustedY + 0.25);

				// Use smoke color at upper edges
				col = lerp(col, _SmokeColor, step(0, adjustedY - (noise.x - 0.1)));

				// Add a transparent smoke effect
				fixed4 smoke = lerp(_SmokeColor, fixed4(_SmokeColor.rgb, 0), saturate(adjustedY+noise*0.35));
				col = lerp(col, smoke, step(0, adjustedY - noise.x));

                return col;
            }
            ENDCG
        }
    }
}
