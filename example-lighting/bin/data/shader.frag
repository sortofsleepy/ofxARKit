precision highp float;

uniform float lightIntensity;
varying vec3 normalInterp;
varying vec3 vertPos;

// shader adapted from this tutorial 
// http://www.mathematik.uni-marburg.de/~thormae/lectures/graphics1/code/WebGLShaderLightMat/ShaderLightMat.html

// lighting should be set as an overhead light.
const vec3 lightPos = vec3(0.0,-2000.0,600.0);

// just set a white diffuse and specular color.
const vec3 diffuseColor = vec3(1.);
const vec3 specColor = vec3(1.0, 1.0, 1.0);

void main(){

	vec3 normal = normalize(normalInterp); 
	vec3 lightDir = normalize(lightPos - vertPos);

	float lambertian = max(dot(lightDir,normal), 0.0);
	float specular = 0.0;


	vec3 light = (lambertian * lightIntensity) * diffuseColor + specular * specColor;
    
	gl_FragColor = vec4( light, 1.0);
}

/*
 if(lambertian > 0.0) {
 
 vec3 reflectDir = reflect(-lightDir, normal);
 vec3 viewDir = normalize(-vertPos);
 
 float specAngle = max(dot(reflectDir, viewDir), 0.0);
 //specular = pow(specAngle, 4.0);
 }
 */
