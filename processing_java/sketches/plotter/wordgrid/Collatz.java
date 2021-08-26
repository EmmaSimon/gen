import java.util.*;

public class Collatz {
  static Map<Integer, Integer> collatz;
  static Map<Integer, Integer> lengths;



  static Integer next(Integer x) {
    if (collatz.containsKey(x)) {
      return collatz.get(x);
    }
    Integer next = x % 2 == 0 ? x / 2 : 3 * x + 1;
    // if (next == 1 && !lengths.containsKey) {
    //   Integer lengthCount = 0;

    //   lengths.put(x, )
    // }
    return next;
  }

}
