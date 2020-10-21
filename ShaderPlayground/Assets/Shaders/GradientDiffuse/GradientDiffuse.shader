Shader "Unlit/GradientDiffuse"
{
    Properties
    {
        _DiffuseRamp ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
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
				fixed dotProduct : TEXCOORD1;
            };

            sampler2D _DiffuseRamp;
			fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				//fixed3 viewDir = ObjSpaceViewDir(v.vertex);
				//o.dotProduct = (dot(v.normal, viewDir)+1) / 2;

				o.dotProduct = (dot(v.normal, _WorldSpaceLightPos0.xyz) + 1) / 2;

				return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				//fixed4 diffuse = tex2D(_DiffuseRamp, fixed2(i.dotProduct, 0.5));
				fixed4 diffuse = tex2D(_DiffuseRamp, fixed2(i.dotProduct, 0));
                fixed4 col = _Color * diffuse;

                return col;
            }
            ENDCG
        }
    }
}
