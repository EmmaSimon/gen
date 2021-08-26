import java.io.File;
import java.io.IOException;
import java.lang.Math;
import java.util.*;

import com.fasterxml.jackson.annotation.*;
import com.fasterxml.jackson.databind.ObjectMapper;

public class State {
  public History history = new History();
  public KeyBindings kb;
  @JsonIgnore File writeFile;
  @JsonIgnore StateInitializer init;
  @JsonIgnore private static final ObjectMapper mapper = new ObjectMapper();
  private static final boolean DEBUG = true;

  State() {}
  State(StateInitializer init) {
    this.setInit(init);
    next();
  }

  State(StateInitializer init, File writeFile) {
    this(init);
    this.setWriteFile(writeFile);
  }

  @JsonIgnore
  StateEntry pushState(HashMap<String, Object> mergeState) {
    return pushState(init.getNewState(history.getCurrent(), mergeState));
  }

  @JsonIgnore
  StateEntry pushState() {
    return pushState(init.getNewState(history.getCurrent()));
  }

  StateEntry pushState(StateEntry newState) {
    history.entries.add(newState);
    history.index = history.entries.size() - 1;
    StateEntry currentState = history.getCurrent();
    if (DEBUG) {
      System.out.println(String.format(
        "Pushing new state, now at %s: %s",
        history.index, currentState
      ));
    }
    return currentState;
  }

  @JsonIgnore
  StateEntry next() {
    history.index++;
    if (history.entries.size() <= history.index) {
      pushState();
      if (DEBUG) {
        System.out.println("No next entry exists, creating a new one.");
      }
    }
    StateEntry state = history.getCurrent();
    if (DEBUG) {
      System.out.println(String.format(
        "Moving to next entry (%s): %s",
        history.index, state
      ));
    }
    return state;
  }
  @JsonIgnore
  StateEntry prev() {
    if (history.index <= 0) {
      System.out.println("That's the last one babe");
    } else {
      history.index--;
    }
    StateEntry currentState = history.getCurrent();
    if (DEBUG) {
      System.out.println(String.format(
        "Moving to previous entry (%s): %s",
        history.index, currentState
      ));
    }
    return currentState;
  }
  @JsonIgnore
  StateEntry setHistoryIndex(int newIndex) {
    if (newIndex < 0 || newIndex > history.entries.size()) {
      System.out.println(String.format("Bad history index (%s) provided", newIndex));
      return history.getCurrent();
    }
    history.index = newIndex;
    StateEntry currentState = history.getCurrent();
    if (DEBUG) {
      System.out.println(String.format(
        "Moving to entry (%s): %s",
        history.index, currentState
      ));
    }
    return currentState;
  }
  @JsonIgnore
  StateEntry erase() {
    return erase(history.index);
  }
  @JsonIgnore
  StateEntry erase(int eraseIndex) {
    if (eraseIndex < 0 || eraseIndex >= history.entries.size()) {
      System.out.println(String.format("Bad delete index (%s) provided", eraseIndex));
      return history.getCurrent();
    }
    if (eraseIndex == 0 && history.entries.size() == 1) {
      history.index = 0;
      history.entries.set(0, this.init.getNewState());
      if (DEBUG) {
        System.out.println("Erasing the final entry.");
      }
      return history.entries.get(0);
    }
    history.entries.remove(eraseIndex);
    history.index = history.index == history.entries.size() - 1 ? history.index - 1 : history.index;
    StateEntry newCurrentState = this.history.getCurrent();
    this.writeStatus();
    if (DEBUG) {
      System.out.println(String.format(
          "Erasing index %s, index is now %s: %s",
          eraseIndex, history.index, newCurrentState
        )
      );
    }
    return newCurrentState;
  }
  @JsonIgnore
  static float[][] toArray(Object value) {
    if (value.getClass().isArray()) {
      return (float[][]) value;
    }
    List<Object> list = (List) value;
    float[][] array = new float[list.size()][];
    for (int i = 0; i < list.size(); i++) {
        List innerList = (List) list.get(i);
        float[] innerArray = new float[innerList.size()];
        for (int j = 0; j < innerList.size(); j++) {
          Number v = (Number) innerList.get(j);
          innerArray[j] = v.floatValue();
        }
        array[i] = innerArray;
    }
    return array;
  }

  @JsonIgnore
  Object get(String stateKey) {
    Object value = history.getCurrent().get(stateKey);
    if (value == null) {
      value = this.init.getNewState().get(stateKey);
      this.history.getCurrent().put(stateKey, value);
    }
    return value;
  }
  @JsonIgnore
  String getString(String stateKey) {
    return (String) get(stateKey);
  }
  @JsonIgnore
  int getInt(String stateKey) {
    return (int) get(stateKey);
  }
  @JsonIgnore
  float getFloat(String stateKey) {
    return (float) get(stateKey);
  }
  @JsonIgnore
  float[][] getPointArray(String stateKey) {
    Object value = get(stateKey);
    return toArray(value);
  }

  @JsonIgnore
  void set(String stateKey, Object value) {
    if (DEBUG) {
      System.out.println(String.format(
        "Setting state %s key %s to value: %s",
        history.index, stateKey, value
      ));
    }
    history.getCurrent().put(stateKey, value);
  }
  @JsonIgnore
  void writeStatus() {
    try {
      mapper.writeValue(writeFile, this);
    } catch (IOException e) {
      System.out.println("Failed to write state to " + writeFile);
      if (DEBUG) {
        System.out.println(e);
      }
    }
  }
  @JsonIgnore
  void setWriteFile(File writeFile) {
    this.writeFile = writeFile;
  }
  @JsonIgnore
  void setInit(StateInitializer init) {
    this.init = init;
  }

  static State loadState(String fileName, StateInitializer init) {
    File historyFile = new File(fileName);
    return State.loadState(historyFile, init);
  }
  static State loadState(File stateFile, StateInitializer init) {
    State loaded;
    try {
      loaded = mapper.readValue(stateFile, State.class);
      loaded.setWriteFile(stateFile);
      loaded.setInit(init);
    } catch (IOException e) {
      System.out.println("Failed to load state file from " + stateFile);
      if (DEBUG) {
        System.out.println(e);
      }
      loaded = new State(init, stateFile);
    }
    return loaded;
  }
}

class StateEntry extends HashMap<String, Object> {
  public StateEntry() {
    super();
  }
  public StateEntry(HashMap<String, Object> mapClone) {
    super(mapClone);
  }
  public StateEntry(StateEntry cloneEntry) {
    super(cloneEntry);
  }
}

@JsonAutoDetect(fieldVisibility = JsonAutoDetect.Visibility.PUBLIC_ONLY)
class History {
  public List<StateEntry> entries = new ArrayList();
  public int index = 0;

  @JsonIgnore
  public StateEntry getCurrent() {
    if (entries.size() == 0) {
      index = 0;
      return null;
    }
    int currentIndex = Math.min(Math.max(index, 0), entries.size() - 1);
    if (currentIndex != index) {
      index = currentIndex;
    }
    // System.out.println(String.format("Getting current (%s): %s", index, entries));
    return entries.get(index);
  }
}

class KeyBindings {

}

class Arrow {
  // public static final Arrow CURLY_BRACES = new Arrow('{', '}');
  // public static final Arrow BRACES = new Arrow('[', ']');
  // public static final Arrow ARROW_LR = new Arrow(LEFT, RIGHT);
  // public static final Arrow ARROW_UD = new Arrow(UP, DOWN);
  // public static final Arrow COMMA_PERIOD = new Arrow(',', '.');
  // public static final Arrow ANGLE_BRACES = new Arrow('<', '>');

  public int back;
  public int forth;
  Arrow(int back, int forth) {
    this.back = back;
    this.forth = forth;
  }
  Arrow(char back, char forth) {
    this.back = Character.getNumericValue(back);
    this.forth = Character.getNumericValue(forth);
  }
}
class NumControls {
  Arrow arrow;
  NumControls(Arrow arrow) {

  }
}
