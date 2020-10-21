Shader "Unlit/NoiseBump"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BumpScale ("Bump Scale", Range(-1,1)) = 0.5
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
				float1 diffuse : TEXCOORD1;
				
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _BumpScale;

            v2f vert (appdata v)
            {
                v2f o;
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float3 offset = (tex2Dlod(_MainTex, float4(o.uv,0,0)).r) * v.normal * _BumpScale;
				v.vertex = v.vertex + float4(offset, 0);
				o.vertex = UnityObjectToClipPos(v.vertex);

				fixed3 lightDir = normalize(WorldSpaceLightDir(v.vertex));
				o.diffuse = dot(lightDir, v.normal) / 2 + 0.5;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                return fixed4(1,1,1,1)*(i.diffuse);
            }
            ENDCG
        }
    }
}
