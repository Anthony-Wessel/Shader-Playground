Shader "Unlit/VariableSaturation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

		_Saturation ("Saturation", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Transparent+1"}
        LOD 100

		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off

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
				fixed4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
				fixed4 color : COLOR;
            };

            sampler2D _MainTex;
			fixed _Saturation;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv = v.uv;

				o.color = v.color;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = tex2D(_MainTex, i.uv) * i.color;

				fixed4 saturatedColor;
				fixed average = (col.r + col.g + col.b) / 3;
				saturatedColor.r = lerp(average, col.r, _Saturation);
				saturatedColor.g = lerp(average, col.g, _Saturation);
				saturatedColor.b = lerp(average, col.b, _Saturation);
				saturatedColor.a = col.a;

                return saturatedColor;
            }
            ENDCG
        }
    }
}
