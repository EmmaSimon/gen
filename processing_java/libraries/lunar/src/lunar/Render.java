package lunar;

public class Render {

	/**
	 * Draws a mesh
	 * @param applet The Processing applet, write "this"
	 * @param mesh The input mesh
	 */
	
	public static final void mesh(processing.core.PApplet applet, LMesh mesh)
	{
		processing.core.PGraphics graphicsBuffer = applet.g;
		
		graphicsBuffer.beginShape(processing.core.PConstants.TRIANGLES);
		
		for(LFace f : mesh.faces)
		{
		    LVector a = mesh.vertices.get(f.a);
		    LVector b = mesh.vertices.get(f.b);
		    LVector c = mesh.vertices.get(f.c);
		    
		    LVector n = Vectors.unitVector(Vectors.crossProduct(Vectors.twoPointVector(a,c),Vectors.twoPointVector(a,b)));
		 
		    
		    graphicsBuffer.normal(n.x, n.y, n.z);
		    graphicsBuffer.vertex(a.x, a.y, a.z);
		    graphicsBuffer.vertex(b.x, b.y, b.z);
		    graphicsBuffer.vertex(c.x, c.y, c.z);
		}
		
		graphicsBuffer.endShape();
	}
	
	/**
	 * Draws the normals of a mesh
	 * @param applet The Processing applet, write "this"
	 * @param mesh The input mesh
	 * @param normalLength The length of the normals
	 */
	
	public static final void meshNormals(processing.core.PApplet applet, LMesh mesh, float normalLength)
	{
		processing.core.PGraphics graphicsBuffer = applet.g;

		graphicsBuffer.beginShape(processing.core.PConstants.LINES);
	
		for (LFace f : mesh.faces)
		{
			LVector a = mesh.vertices.get(f.a);
			LVector b = mesh.vertices.get(f.b);
		    LVector c = mesh.vertices.get(f.c);
		
		    LVector m = Vectors.dividedVector(Vectors.addedVector(Vectors.addedVector(a, b), c), 3);		
		    LVector n = Vectors.unitVector(Vectors.crossProduct(Vectors.twoPointVector(a, c), Vectors.twoPointVector(a, b)));		
		    LVector v = Vectors.addedVector(m, Vectors.amplitudedVector(n, normalLength));
		
		    graphicsBuffer.line(m.x, m.y, m.z, v.x, v.y, v.z);
		}

  		graphicsBuffer.endShape();
	}
	
	/**
	 * Draws the vertices of a mesh
	 * @param applet The Processing applet, write "this"
	 * @param mesh The input mesh
	 */
	
	public static final void meshVertices(processing.core.PApplet applet, LMesh mesh)
	{
	  processing.core.PGraphics graphicsBuffer = applet.g;

	  graphicsBuffer.beginShape(processing.core.PConstants.POINTS);
	  
	  for (LVector v : mesh.vertices) graphicsBuffer.point(v.x, v.y, v.z);  
	  
	  graphicsBuffer.endShape();
	}
	
	/**
	 * Draws a mesh as a rainbow mesh
	 * @param applet The Processing applet, write "this"
	 * @param mesh The input mesh
	 */
	
	public static final void rainbowMesh(processing.core.PApplet applet, LMesh mesh)
	{
		processing.core.PGraphics graphicsBuffer = applet.g;

		graphicsBuffer.beginShape(processing.core.PConstants.TRIANGLES);

		  for (LFace f : mesh.faces)
		  {
		    LVector a = mesh.vertices.get(f.a);
		    LVector b = mesh.vertices.get(f.b);
		    LVector c = mesh.vertices.get(f.c);

		    LVector n = Vectors.unitVector(Vectors.crossProduct(Vectors.twoPointVector(a, c), Vectors.twoPointVector(a, b)));

		    LVector colour = new LVector(
		    		processing.core.PApplet.map(n.x, -0.87f, 0.87f, 0, 255), 
		    		processing.core.PApplet.map(n.y, -0.87f, 0.87f, 0, 255), 
		    		processing.core.PApplet.map(n.z, -0.87f, 0.87f, 0, 255)
		    );

		    graphicsBuffer.fill(colour.x, colour.y, colour.z);

		    graphicsBuffer.normal(n.x, n.y, n.z);
		    graphicsBuffer.vertex(a.x, a.y, a.z);
		    graphicsBuffer.vertex(b.x, b.y, b.z);
		    graphicsBuffer.vertex(c.x, c.y, c.z);
		  }

		  graphicsBuffer.endShape();
	}
	
	/**
	 * Draws the background as a gradient
	 * @param applet The Processing applet, write "this"
	 * @param colourA The first colour
	 * @param colourB The second colour
	 */
	
	public static final void gradientBackground(processing.core.PApplet applet, int colourA, int colourB)
	{
		processing.core.PGraphics graphicsBuffer = applet.g;

		graphicsBuffer.hint(processing.core.PConstants.DISABLE_DEPTH_TEST);
		graphicsBuffer.pushMatrix();
		graphicsBuffer.resetMatrix();
		processing.opengl.PGraphicsOpenGL pgl = (processing.opengl.PGraphicsOpenGL)graphicsBuffer;
		boolean pushedLights = pgl.lights;
		pgl.lights = false;
		pgl.pushProjection();
		graphicsBuffer.ortho(0, graphicsBuffer.width, graphicsBuffer.height, 0, -Float.MAX_VALUE, +Float.MAX_VALUE);
		  
		graphicsBuffer.noFill();
		graphicsBuffer.strokeWeight(1);

		for (int i = 0; i <= applet.height; i++)
		{
			float t = processing.core.PApplet.map(i, 0, applet.height, 0, 1);
		    int colourC = applet.lerpColor(colourA, colourB, t);
		    graphicsBuffer.stroke(colourC);
		    graphicsBuffer.line(0, -i, applet.width, -i);
		}

		pgl.popProjection();
		pgl.lights = pushedLights;
		graphicsBuffer.popMatrix();
		graphicsBuffer.hint(processing.core.PConstants.ENABLE_DEPTH_TEST);
	}
	
	/**
	 * Creates a static camera
	 * @param applet The Processing applet, write "this"
	 * @param target The position the camera is looking towards to
	 * @param position The position of the camera
	 */
	
	public static final void staticCamera(processing.core.PApplet applet, LVector target, LVector position)
	{
		applet.camera(position.x, position.y, position.z, target.x, target.y, target.z, 0, 0, -1);
	}
	
	/**
	 * Creates a camera that orbits around a target point
	 * @param applet The Processing applet, write "this"
	 * @param target The position the camera is looking towards to
	 * @param polarPosition The position of the camera as a three-dimensional polar coordinate
	 */
	
	public static void orbitCamera(processing.core.PApplet applet, LVector target, LVector polarPosition)
	{
		LVector position = new LVector
		(
			(float)(java.lang.Math.cos(polarPosition.y)*polarPosition.x), 
			(float)(java.lang.Math.sin(polarPosition.y)*polarPosition.x), 
			(float)(java.lang.Math.sin(polarPosition.z)*polarPosition.x)
	    );

		position = Vectors.addedVector(position, target);

		applet.camera(position.x, position.y, position.z, target.x, target.y, target.z, 0, 0, -1);
	}
	
	/**
	 * Creates a camera that around a target points, dependent on the mouse position
	 * @param applet The Processing applet, write "this"
	 * @param target The position the camera is looking towards to
	 * @param cameraDistance The distance of the camera to the target
	 */
	
	public static void mouseCamera(processing.core.PApplet applet, LVector target, float cameraDistance)
	{
		LVector mousePosition = new LVector
		(
			cameraDistance, 
			processing.core.PApplet.map(applet.mouseX, 0, applet.width, (float)java.lang.Math.PI, (float)-java.lang.Math.PI), 
			processing.core.PApplet.map(applet.mouseY, 0, applet.height, (float)java.lang.Math.PI/2, (float)-java.lang.Math.PI/2) 
		);

		orbitCamera(applet, target, mousePosition);
	}
	
}
