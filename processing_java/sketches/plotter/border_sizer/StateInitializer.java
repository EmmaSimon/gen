import java.util.*;

public abstract class StateInitializer {
  StateEntry getNewState(HashMap<String, Object>... mergeMaps) {
    HashMap stateMap = new HashMap<String, Object>(getStateTemplate());
    for (HashMap<String, Object> map : mergeMaps) {
      stateMap.putAll(map);
    }
    return new StateEntry(stateMap);
  }
  abstract HashMap<String, Object> getStateTemplate();
}
