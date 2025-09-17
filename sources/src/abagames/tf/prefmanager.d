/*
 * $Id: prefmanager.d,v 1.3 2004/05/14 14:35:37 kenta Exp $
 *
 * Copyright 2004 Kenta Cho. All rights reserved.
 */
module abagames.tf.prefmanager;

private import std.stdio;
private import std.process;
private import std.file;
private import std.path;
version (Windows) {
    private import std.process;
}
private import abagames.util.prefmanager;

/**
 * Save/Load the high score.
 */
public class PrefManager: abagames.util.prefmanager.PrefManager {
 public:
  static const int VERSION_NUM = 20;
  static string PREF_FILE = "tf.prf"; // Will be overridden at runtime
  static const int RANKING_NUM = 7;  // we leave room for options menu below
  static const int DEFAULT_HISCORE = 10000;
  RankingItem[RANKING_NUM] ranking;

  private static string getPrefFilePath() {
    string homeDir = "";
    string prefDir = "";
    
    version (Windows) {
      // Windows: Use APPDATA environment variable
      homeDir = environment.get("APPDATA", "");
      if (homeDir.length > 0) {
        prefDir = buildPath(homeDir, "tumikifighters");
      }
    } else {
      // Unix-like systems (Linux, macOS, etc.): Use HOME environment variable
      homeDir = environment.get("HOME", "");
      if (homeDir.length > 0) {
        // Use XDG Base Directory specification
        string xdgDataHome = environment.get("XDG_DATA_HOME", "");
        if (xdgDataHome.length > 0) {
          prefDir = buildPath(xdgDataHome, "tumikifighters");
        } else {
          // Default to ~/.local/share/tumikifighters
          prefDir = buildPath(homeDir, ".local", "share", "tumikifighters");
        }
      }
    }
    
    // If we have a valid preference directory, try to create it and use it
    if (prefDir.length > 0) {
      try {
        mkdirRecurse(prefDir);
        return buildPath(prefDir, "tf.prf");
      } catch (Exception) {
        // If we can't create the directory, fall back to current directory
        // if installed, the executable directory won't be writable
        return "tf.prf";
      }
    }
    return "tf.prf";
  }

  public this() {
    // Set the preferences file path at runtime
    PREF_FILE = getPrefFilePath();
    
    foreach (ref RankingItem ri; ranking)
      ri = new RankingItem;
  }

  private void init() {
    int sc = DEFAULT_HISCORE * RANKING_NUM;
    foreach (RankingItem ri; ranking) {
      ri.score = sc;
      ri.stage = 0;
      sc -= DEFAULT_HISCORE;
    }
  }

  public void load() {
    scope File fd;
    try {
      int[1] read_data;
      fd.open(PREF_FILE);
      fd.rawRead(read_data);
      if (read_data[0] != VERSION_NUM)
	throw new Exception("Wrong version num");
      foreach (RankingItem ri; ranking)
	ri.load(fd);
    } catch (Exception e) {
      init();
    } finally {
      fd.close();
    }
  }

  public void save() {
    scope File fd;
    try {
      fd.open(PREF_FILE, "wb");
      const int[1] write_data = [VERSION_NUM];
      fd.rawWrite(write_data);
      foreach (RankingItem ri; ranking)
        ri.save(fd);
    } finally {
      fd.close();
    }
  }

  public void setHiScore(int sc, int st) {
    int i = 0;
    for (; i < RANKING_NUM; i++)
      if (ranking[i].score < sc)
	break;
    if (i >= RANKING_NUM)
      return;
    for (int j = RANKING_NUM - 1; j > i; j--)
      ranking[j] = ranking[j - 1];
    ranking[i] = new RankingItem(sc, st);
  }
}

public class RankingItem {
 public:
  int score;
  int stage;

  public this() {
    score = stage = 0;
  }

  public this(int sc, int st) {
    score = sc;
    stage = st;
  }

  public void save(File fd) {
    const int[2] write_data = [score, stage];
    fd.rawWrite(write_data);
  }

  public void load(File fd) {
    int[2] read_data;
    fd.rawRead(read_data);
    score = read_data[0];
    stage = read_data[1];
  }
}
