panel = {
    'seed': widgets.IntSlider(
        min=-10000,
        max=10000,
        step=1,
        description='seed',
        orientation='vertical',
        value=0
    ),
    'counter': widgets.IntSlider(
        min=0,
        max=100,
        step=1,
        description='counter',
        orientation='vertical',
        value=3
    ),
    'scale': widgets.FloatSlider(
        min=1,
        max=30,
        step=.2,
        description='scale',
        orientation='vertical',
        value=10
    ),
    'multiplier': widgets.FloatSlider(
        min=-50,
        max=50,
        step=.1,
        description='multiplier',
        orientation='vertical',
        value=0
    ),
    'angle': widgets.FloatSlider(
        min=-math.tau,
        max=math.tau,
        step=.01,
        description='angle',
        orientation='vertical',
        value=0
    ),
    'x': widgets.FloatSlider(
        min=-1000,
        max=1000,
        step=.5,
        description='x',
        orientation='vertical',
        value=0
    ),
    'y': widgets.FloatSlider(
        min=-1000,
        max=1000,
        step=.5,
        description='y',
        orientation='vertical',
        value=0
    ),
}

class SketchProp:
    def __init__(
        self,
        key, # The key to access this prop with, required
        osc_address=None, # The OSC address to r/w this prop to
        description='Fuck if I know.', # A helpful description of the prop
        init=0, # The initial value to set the prop to
        min=-100, # The minimum value, set to None for none
        max=100, # The max value, set to None for none
        step=1, # The step by which to change this value by per tick
    ):
        self.key = key
        self.osc_address = osc_address
        self.description = description
        self.init = init
        self.min = min
        self.max = max
        self.step = step
        self.value = init
        self.dispatcher = None

    def handler(self, address, *osc_arguments):
        print(address, osc_arguments)
        self.value = osc_arguments[0]


    def init_handler(self):
        if (self.osc_address is None):
            raise RuntimeError(f"\n\n{key} was not provided, an osc_address, no handler can be initialized")
        if (self.dispatcher is None):
            raise RuntimeError(f"\n\nCan't write to {self.key}@{self.osc_address}, no dispatcher was provided")
        self.dispatcher.map(self.osc_address, self.handler)
        

    def write(self, next_value, osc_client):
        prev_value = self.value
        self.value = next_value
        if (osc_client):
            osc_client.send_message(self.key, )



# Sketch props setup configs are maps containing the name and details 
# of every prop used by a sketch. It can contain these options:
demo_props = {
      'props': [
          '{key}': {
              'description': 'A string explaining what this prop does',
              'init': 666 # The initial value for the prop
              'min': 0 # The minimum
          }
      ] 

   }
