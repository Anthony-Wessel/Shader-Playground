﻿Shader "Unlit/Toon"
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
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float lighting : texcoord1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.lighting = (dot(normalize(_WorldSpaceLightPos0), UnityObjectToWorldNormal(v.normal)) + 1) / 2;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float steppedLighting = ceil(i.lighting * 2) / 2;
                fixed4 col = tex2D(_MainTex, i.uv) * steppedLighting;

                return col;
            }
            ENDCG
        }
    }
}
