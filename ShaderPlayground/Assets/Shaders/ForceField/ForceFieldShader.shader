Shader "Unlit/ForceFieldShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex ("Noise", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
		{
			"Queue" = "Overlay" // Render this over other objects
			"IgnoreProjector" = "True" // not affected by projectors
			"RenderType" = "Transparent"
		}

		Pass
        {
			Lighting Off
			ZWrite Off // Should be off for semi-transparent objects
			Blend SrcAlpha OneMinusSrcAlpha // blend allows for transparancy
			Cull Off // Don't cull any faces (render front and back faces)

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
				fixed dotProduct : TEXCOORD2;
				fixed4 screenPos : TEXCOORD3;
            };

            sampler2D _MainTex, _CameraDepthTexture, _NoiseTex;
            float4 _MainTex_ST;

			fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				// Calculate viewDir based on camera position
				fixed3 viewDir = normalize(ObjSpaceViewDir(v.vertex));

				// will be 0 when surface is perpendicular to view dir
				// will be 1 when surface is pointed directly at or away from camera
				o.dotProduct = 1.0-abs(dot(v.normal, normalize(viewDir)));
				
				// compute screen position
				o.screenPos = ComputeScreenPos(o.vertex);
				// compute depth
				COMPUTE_EYEDEPTH(o.screenPos.z);

                return o;
            }

            fixed4 frag (v2f i, fixed face : VFACE) : SV_Target
            {
				// Get initial color based on texture
				fixed4 result = tex2D(_MainTex, i.uv) + fixed4(0.2, 0.2, 0.2, 0.2);
				
				// Set alpha based on texture
				result.w = saturate(1 - result.r)+0.05;

				// Calculate intersection with other objects (0-1 where 1 is intersected)
				fixed intersect = saturate(abs(LinearEyeDepth(tex2Dproj(_CameraDepthTexture, i.screenPos).r) - i.screenPos.z)/0.1);
				
				// Calculate fresnel effect
				fixed fresnel = saturate(lerp(0.1, 1, i.dotProduct*i.dotProduct));
				
				// Determine whether or not to use the intersection
				fixed addition = lerp(1, fresnel, intersect);

				// Adjust alpha based on fresnel and intersection
				result.w += addition;

				// Add scrolling noise to the texture
				fixed4 noise = tex2D(_NoiseTex, i.uv+fixed2(0, _Time.y/4));
				result.w *= noise;
				                
				return result * _Color;
            }
            ENDCG
        }
	
	}
}
