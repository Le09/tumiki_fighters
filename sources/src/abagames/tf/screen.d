/*
 * $Id: screen.d,v 1.3 2004/05/14 14:35:38 kenta Exp $
 *
 * Copyright 2004 Kenta Cho. All rights reserved.
 */
module abagames.tf.screen;

private import std.math;
private import opengl;
private import abagames.util.sdl.screen3d;

/**
 * Initialize an OpenGL and set the caption.
 */
public class Screen: Screen3D {
 public:
  static string CAPTION = "TUMIKI Fighters";

  protected override void init() {
    setCaption(CAPTION);
    glLineWidth(1);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glEnable(GL_LINE_SMOOTH);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glDisable(GL_BLEND);
    glDisable(GL_LIGHTING);
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_COLOR_MATERIAL);
    setClearColor(0, 0, 0, 1);
  }

  public override void close() {
  }

  public override void clear() {
    // Get current viewport (the game area)
    int[4] gameViewport;
    glGetIntegerv(GL_VIEWPORT, gameViewport.ptr);
    
    // Only clear letterbox/pillarbox areas if viewport doesn't fill entire screen
    if (gameViewport[0] > 0 || gameViewport[1] > 0 || 
        gameViewport[2] < screenWidth || gameViewport[3] < screenHeight) {
      
      // Save current clear color
      float[4] currentClearColor;
      glGetFloatv(GL_COLOR_CLEAR_VALUE, currentClearColor.ptr);
      
      // Clear entire screen with black first
      glViewport(0, 0, screenWidth, screenHeight);
      glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      
      // Restore game viewport and original clear color
      glViewport(gameViewport[0], gameViewport[1], gameViewport[2], gameViewport[3]);
      glClearColor(currentClearColor[0], currentClearColor[1], currentClearColor[2], currentClearColor[3]);
    }
    
    // Clear the game area with the proper background color
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  }

  public void viewOrthoFixed() {
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    glOrtho(0, 640, 480, 0, -1, 1);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();
  }

  public void viewPerspective() {
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();
  }
}
