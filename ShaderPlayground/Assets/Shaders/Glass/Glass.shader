Shader "Unlit/Glass"
{
    Properties
    {
		_RimPower("Rim Power", Range(0,4)) = 2
		_RimLightMultiplier("Rim Light Multiplier", Range(1,2)) = 1.5
		_Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        LOD 100

        Pass
        {
			Name "GlassMain"
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			ZWrite Off
			Lighting Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				fixed3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				fixed rim : TEXCOORD1;
            };

			fixed _RimLightMultiplier, _RimPower;
			fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

				fixed3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
				o.rim = abs(dot(v.normal, viewDir));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 col = _Color * (1-i.rim) * _RimLightMultiplier;
				col.w = pow(1 - i.rim, _RimPower);
                return col;
            }
            ENDCG
        }
    }
}
