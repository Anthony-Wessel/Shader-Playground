Shader "Unlit/DiffuseVsSpecular"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_Smoothness ("Smoothness", Range(0,1)) = 0
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
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float diffuse : TEXCOORD1;
            };

			fixed4 _Color;
			float _Smoothness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

				float lightDir = _WorldSpaceLightPos0;
				float3 worldNormal = (mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz;
				o.diffuse = dot(normalize(_WorldSpaceLightPos0), worldNormal);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _Color * pow(i.diffuse, _Smoothness*10+1);

                return col;
            }
            ENDCG
        }
    }
}
