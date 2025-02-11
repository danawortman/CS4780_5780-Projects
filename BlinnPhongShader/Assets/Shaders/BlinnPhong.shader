Shader "Custom/BlinnPhong"
{
    Properties {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(0, 1)) = 1
        [Toggle] _UseAmbient ("Use Ambient", Float) = 1
	} 
	SubShader {
        Tags { "RenderType" = "Opaque" }
        Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "UnityShaderVariables.cginc"
	        float _Gloss;
			float4 _Color;
			float _UseAmbient;
			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f {
				float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};
			v2f vert (appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = v.normal;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			float4 frag (v2f i) : SV_Target {
				float3 N = normalize(i.normal);
				float3 L = _WorldSpaceLightPos0.xyz;
				float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
				// diffuse lighting (lambertian)
				float lambert = saturate(dot(N, L));
				float3 diffuseLight = lambert * _LightColor0.xyz;
				float3 diffuseColor = diffuseLight * _Color;
				// ambient lighting (direct from Unity settings)
				float3 ambientLight = UNITY_LIGHTMODEL_AMBIENT.xyz;
                ambientLight = ambientLight * (_UseAmbient > 0);
				// specular lighting (Blinn-Phong)
				float3 H = normalize(L + V);
				float specExponent = exp2(_Gloss * 8) + 2;
				float3 specularLight = saturate(dot(N, H)) * (lambert > 0);
				specularLight = pow(specularLight, specExponent) * _LightColor0.xyz;
				return float4(diffuseColor + ambientLight + specularLight, 1);
			}
			ENDCG
		}
    }
}
