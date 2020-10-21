Shader "Unlit/Potion"
{
    Properties
    {
		_FillLevel("Fill Level", Range(0,1)) = 0.5

		[Header(Liquid Shader Properties)]
		[Space]
		_BaseColor("Base Color", Color) = (0.9,0,0,1)
		_TopColor("Top Color", Color) = (1,0,0,1)
		_TopThickness("Top Thickness", Range(0,0.2)) = 0.05

		// Glass shader parameters
		[Header(Glass Shader Properties)]
		[Space]
		_RimPower("Rim Power", Range(0,4)) = 2
		_RimLightMultiplier("Rim Light Multiplier", Range(1,2)) = 1.5
		_Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType"="Transparent" }

        Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
				float4 vertex : SV_POSITION;
				float3 localPos : TEXCOORD1;
            };

			fixed4 _TopColor;
			fixed _FillLevel;

            v2f vert (appdata v)
            {
                v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.localPos = mul(v.vertex, unity_ObjectToWorld)
						   - mul(fixed4(0,0,0,1), unity_ObjectToWorld);

                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{
				fixed percentFilled = _FillLevel - 0.5;
				if (i.localPos.y < percentFilled)
				{
					return _TopColor;
				}
				return fixed4(0, 0, 0, 0);
            }
            ENDCG
        }

// --------------------------------------------------------------------------

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Back

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 localPos : TEXCOORD1;
			};

			fixed4 _BaseColor, _TopColor;
			fixed _FillLevel, _TopThickness;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.localPos = mul(v.vertex, unity_ObjectToWorld)
						   - mul(fixed4(0, 0, 0, 1), unity_ObjectToWorld);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed percentFilled = _FillLevel - 0.5;
				if (i.localPos.y < percentFilled)
				{
					if (i.localPos.y < percentFilled-_TopThickness)
						return _BaseColor;
					else return _TopColor*0.95;
				}
				return fixed4(0, 0, 0, 0);
			}
			ENDCG
		}

		UsePass "Unlit/Glass/GlassMain"

    }
}
