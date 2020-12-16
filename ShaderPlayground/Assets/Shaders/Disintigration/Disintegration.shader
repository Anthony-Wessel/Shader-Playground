Shader "Unlit/Disintegration"
{
	Properties
	{
		_Noise("Noise", 2D) = "white" {}
		_Progress("Progress", Range(0.25,0.8)) = 0.25
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2g
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			struct g2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			sampler2D _Noise;
			float4 _Noise_ST;
			float _Progress;

			v2g vert(appdata v)
			{
				v2g o;

				o.vertex = v.vertex;
				o.uv = TRANSFORM_TEX(v.uv, _Noise);

				return o;
			}

			[maxvertexcount(3)]
			void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
			{
				g2f o;

				float3 avgPos = (IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3;
				float2 avgUV = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;

				//float4 noise = tex2Dlod(_Noise, fixed4(avgUV,0,0));
				float4 displacement;

				for (int i = 0; i < 3; i++)
				{
					o.uv = IN[i].uv;
					displacement = lerp(0, 1, step(0, (IN[i].vertex.y + 1) / 2 - _Progress));
					o.vertex = UnityObjectToClipPos(IN[i].vertex + float4(0, 5, 0, 0) * displacement);
					o.color = lerp(fixed4(0, 0, 0, 0), fixed4(5, 5, 5, 5), displacement);
					triStream.Append(o);
				}
			}

			fixed4 frag(g2f i) : SV_Target
			{
				fixed4 col = tex2D(_Noise, i.uv) + i.color;

				return col;
			}
			ENDCG
		}
	}
}
