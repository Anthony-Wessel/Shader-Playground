Shader "Unlit/FallingCubes"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
			};

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2g vert (appdata v)
            {
                v2g o;
				//if (v.vertex.y > 0) v.vertex.y += 5;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

			[maxvertexcount(6)]
			void geom(triangle v2g i[3], inout TriangleStream<g2f> triangleStream)
			{
				g2f o;

				fixed4 up = (i[1].vertex - i[0].vertex)/2;
				fixed4 right = (i[2].vertex - i[0].vertex)/2;
				fixed4 pos;

				for (int x = 0; x < 3; x++)
				{
					for (int y = 2-x; y >= 0; y--)
					{
						pos = i[0].vertex + (right * x) + (up * y);

						o.uv = i[0].uv;
						o.vertex = pos;
						//if (o.vertex.y > 0.5) o.vertex.y += 2;
						triangleStream.Append(o);
					}
				}
			}

            fixed4 frag (g2f i) : SV_Target
            {
                //fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 col = fixed4(1, 1, 1, 1);

                return col;
            }
            ENDCG
        }
    }
}
