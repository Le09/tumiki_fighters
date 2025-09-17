/*
 * $Id: attractmanager.d,v 1.3 2004/05/14 14:35:37 kenta Exp $
 *
 * Copyright 2004 Kenta Cho. All rights reserved.
 */
module abagames.tf.attractmanager;

private import std.string;
private import std.conv;
private import opengl;
private import abagames.util.sdl.pad;
private import abagames.tf.gamemanager;
private import abagames.tf.prefmanager;
private import abagames.tf.tumiki;
private import abagames.tf.letterrender;
private import abagames.tf.stagemanager;

/**
 * Manage the title screen.
 */
public class AttractManager {
 private:
  Pad pad;
  PrefManager prefManager;
  GameManager gameManager;
  int cnt;
  bool btnPrsd;
  bool btn2Prsd;
  bool arrowPrsd;
  bool upDownPrsd;
  int selectedLevel;
  int selectedOption; // 0 = level, 1 = mode, 2 = boss rush, 3 = bullet slowdown
  bool optionsVisible;
  bool bossRushMode;
  bool bulletSlowdown;

  public this(Pad pad, PrefManager pm, GameManager gm) {
    this.pad = pad;
    prefManager = pm;
    gameManager = gm;
  }

  public void startTitle() {
    cnt = 0;
    btnPrsd = true;
    btn2Prsd = true;
    arrowPrsd = true;
    upDownPrsd = true;
    selectedLevel = 0;
    selectedOption = 0;
    optionsVisible = false;
    bossRushMode = false;
    bulletSlowdown = false;
  }

  public void moveTitle() {
    cnt++;
    if (cnt <= 16) {
      btnPrsd = true;
      btn2Prsd = true;
      arrowPrsd = true;
      upDownPrsd = true;
    } else {
      // Button 1 to start game with selected options
      if (pad.getButtonState() & Pad.PAD_BUTTON1) {
        if (!btnPrsd) {
          // Apply bullet slowdown setting
          gameManager.nowait = !bulletSlowdown;
          
          if (bossRushMode) {
            gameManager.startBossRushAtLevel(selectedLevel);
          } else {
            gameManager.startInGameAtLevel(selectedLevel);
          }
          return;
        }
      } else {
        btnPrsd = false;
      }
      
      // Button 2 to toggle options visibility
      if (pad.getButtonState() & Pad.PAD_BUTTON2) {
        if (!btn2Prsd) {
          optionsVisible = !optionsVisible;
        }
        btn2Prsd = true;
      } else {
        btn2Prsd = false;
      }
      
      // Handle navigation only when options are visible
      if (optionsVisible) {
        // Left/Right navigation
        int arrowState = pad.getPadState() & (Pad.PAD_LEFT | Pad.PAD_RIGHT);
        if (arrowState != 0) {
          if (!arrowPrsd) {
            arrowPrsd = true;
            if (selectedOption == 0) {
              // Level selection
              if ((arrowState & Pad.PAD_LEFT) != 0) {
                selectedLevel--;
                if (selectedLevel < 0) selectedLevel = StageManager.STAGE_NUM - 1;
              }
              if ((arrowState & Pad.PAD_RIGHT) != 0) {
                selectedLevel++;
                if (selectedLevel >= StageManager.STAGE_NUM) selectedLevel = 0;
              }
            } else if (selectedOption == 1) {
              // Mode selection
              if ((arrowState & Pad.PAD_LEFT) != 0 || (arrowState & Pad.PAD_RIGHT) != 0) {
                gameManager.getShip().toggleRevMode();
              }
            } else if (selectedOption == 2) {
              // Boss rush selection
              if ((arrowState & Pad.PAD_LEFT) != 0 || (arrowState & Pad.PAD_RIGHT) != 0) {
                bossRushMode = !bossRushMode;
              }
            } else if (selectedOption == 3) {
              // Bullet slowdown selection
              if ((arrowState & Pad.PAD_LEFT) != 0 || (arrowState & Pad.PAD_RIGHT) != 0) {
                bulletSlowdown = !bulletSlowdown;
              }
            }
          }
        } else {
          arrowPrsd = false;
        }
        
        // Up/Down navigation between options
        int upDownState = pad.getPadState() & (Pad.PAD_UP | Pad.PAD_DOWN);
        if (upDownState != 0) {
          if (!upDownPrsd) {
            upDownPrsd = true;
            if ((upDownState & Pad.PAD_UP) != 0) {
              selectedOption--;
              if (selectedOption < 0) selectedOption = 3;
            }
            if ((upDownState & Pad.PAD_DOWN) != 0) {
              selectedOption++;
              if (selectedOption > 3) selectedOption = 0;
            }
          }
        } else {
          upDownPrsd = false;
        }
      }
    }
  }

  public void drawTitle() {
    int c = cnt % 1200;
    if (c < 300) {
      drawTitleBoard(70, 50, 16);
    } else {
      drawTitleBoard(30, 360, 8);
      
      int dr = (c - 300) / 30;
      if (dr > PrefManager.RANKING_NUM)
        dr = PrefManager.RANKING_NUM;
      for (int i = 0; i < dr; i++) {
        char[] rs = to!string(i + 1).dup;
        float x = 100;
        float y = i * 30 + 32;
        switch (i) {
        case 0:
          rs ~= "ST";
          break;
        case 1:
          rs ~= "ND";
          break;
        case 2:
          rs ~= "RD";
          break;
        case 9:
          x -= 19;
          goto default;
        default:
          rs ~= "TH";
          break;
        }
        LetterRender.drawString
          (rs, x, y, 9, LetterRender.Direction.TO_RIGHT, 3);
        LetterRender.drawNum(prefManager.ranking[i].score, 400, y, 9,
                     LetterRender.Direction.TO_RIGHT, 3);
        if (prefManager.ranking[i].stage >= StageManager.STAGE_NUM)
          rs = "A".dup;
        else
          rs = to!string(prefManager.ranking[i].stage + 1).dup;
        LetterRender.drawString
          (rs, 500, y, 9, LetterRender.Direction.TO_RIGHT, 3);
      }
    }
    
    // Draw inline options when visible
    if (optionsVisible) {
      // Level selection row
      string levelText = "LEVEL " ~ to!string(selectedLevel + 1);
      int levelColor = (selectedOption == 0) ? 0 : 2;
      LetterRender.drawString(levelText, 200, 240, 10, LetterRender.Direction.TO_RIGHT, levelColor);
      
      // Mode selection row  
      string modeText = "MODE " ~ (gameManager.getShip().getRevMode() ? "REV" : "ORIGINAL");
      int modeColor = (selectedOption == 1) ? 0 : 2;
      LetterRender.drawString(modeText, 200, 270, 10, LetterRender.Direction.TO_RIGHT, modeColor);
      
      // Boss rush selection row
      string bossRushText = "BOSS RUSH " ~ (bossRushMode ? "ON" : "OFF");
      int bossRushColor = (selectedOption == 2) ? 0 : 2;
      LetterRender.drawString(bossRushText, 200, 300, 10, LetterRender.Direction.TO_RIGHT, bossRushColor);
      
      // Bullet slowdown selection row
      string bulletSlowdownText = "BULLET SLOWDOWN " ~ (bulletSlowdown ? "ON" : "OFF");
      int bulletSlowdownColor = (selectedOption == 3) ? 0 : 2;
      LetterRender.drawString(bulletSlowdownText, 200, 330, 10, LetterRender.Direction.TO_RIGHT, bulletSlowdownColor);
    }
    
    // Instructions
    if (cnt % 64 < 32) {
        LetterRender.drawString("BOMB TO TOGGLE OPTIONS", 250, 380, 6, LetterRender.Direction.TO_RIGHT, 3);
        LetterRender.drawString("PUSH SHOT BUTTON TO START", 250, 400, 7, LetterRender.Direction.TO_RIGHT, 3);
    }
  }

  private const int[][] TITLE_PTN =
    [
     [-4,-1,-1,-1,-1,-1,-1,-1,-1,-0,-0,-0,-0,-0,],
     [-0,-1,19,20,12, 8,10, 8,-1,-0,-0,-0,-0,-0,],
     [-0,-1,-1,-1,-1,-1,-1,-1,-1,-2,-0,-0,-0,-0,],
     [-0,-0,-4,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-0,],
     [-0,-0,-0,-1, 5, 8, 6, 7,19, 4,17,18,-1,-0,],
     [-0,-0,-0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-2,],
     ];
  private const int[][] TITLE_CLR =
    [
     [ 0, 1, 2, 3, 4, 5, 1, 2, 3,-1,-1,-1,-1,-1,],
     [-1, 2, 5, 1, 3, 0, 2, 3, 1,-1,-1,-1,-1,-1,],
     [-1, 5, 2, 3, 0, 4, 1, 4, 5, 2,-1,-1,-1,-1,],
     [-1,-1, 3, 5, 1, 2, 4, 1, 0, 3, 4, 1, 5,-1,],
     [-1,-1,-1, 2, 4, 3, 1, 4, 5, 2, 0, 3, 2,-1,],
     [-1,-1,-1, 1, 5, 0, 3, 1, 3, 4, 5, 2, 1, 3,],
     ];

  private void drawTitleBoard(float x, float y, float s) {
    glPushMatrix();
    glTranslatef(x, y, 0);
    glScalef(s, s, s);
    int tx, ty;
    ty = 0;
    foreach (const int[] tpl; TITLE_PTN) {
      tx = 0;
      foreach (int tp; tpl) {
	int c = TITLE_CLR[ty][tx];
	glPushMatrix();
	glTranslatef(tx * 2, ty * 2, 0);
	if (tp < 0) {
	  int ti = -tp - 1;
	  glScalef(0.75, 0.75, 0.75);
	  glCallList(Tumiki.displayListIdx + ti + c * Tumiki.SHAPE_NUM);
	} else if (tp > 0) {
	  int li = tp + 10;
	  glScalef(0.9, 0.9, 0.9);
	  glCallList(LetterRender.displayListIdx + li + c * LetterRender.LETTER_NUM);
	}
	glPopMatrix();
	tx++;
      }
      ty++;
    }
    glPopMatrix();
    
    // Add "REV 2" subtitle below the title board
    float subtitleSize = s * 0.625; // Scale subtitle relative to title size
    float subtitleY = y + (subtitleSize * 18); // Position below title
    float subtitleX = x + (s * 20); // Center horizontally
    LetterRender.drawString("REV 2", subtitleX, subtitleY, subtitleSize, LetterRender.Direction.TO_RIGHT, 1);
  }
}
