import inspect

######TODO####################
# tuple -> list
# ndarray mappings

def generate_step(cwl, ins=None, outs=None):
    def _generate_step(func):
        def wrapper(*args, **kwargs):
            cwl["steps"][str(func.__name__)] = {}
            cwl["steps"][str(func.__name__)]["run"] = {}
            cwl["steps"][str(func.__name__)]["run"]["class"] = "Operation"
            cwl["steps"][str(func.__name__)]["run"]["inputs"] = {}
            cwl["steps"][str(func.__name__)]["run"]["outputs"] = {}
            cwl["steps"][str(func.__name__)]["in"] = ins
            cwl["steps"][str(func.__name__)]["out"] = outs

            for key, val in kwargs.items():
                #try to get the datatype of val; its possible it fails
                datatype = get_type(val)
                #print(datatype)
                label = None
                if datatype is None:
                    #this failed; its a complex type; for now assign as string
                    datatype = "string"
                    label = str(type(val).__name__) 
                #add the info to inputs
                cwl["steps"][str(func.__name__)]["run"]["inputs"][key] = {}
                cwl["steps"][str(func.__name__)]["run"]["inputs"][key]["type"] = datatype
                if label is not None:
                    cwl["steps"][str(func.__name__)]["run"]["inputs"][key]["label"] = label

            returned_value =  func(*args,**kwargs)
            
            #now we add the return types
            if not isinstance(returned_value, (list, tuple)):
                rv_list = [returned_value]
            else:
                rv_list = returned_value

            if (len(rv_list) != len(outs)):
                raise ValueError("make sure labels are same length and order")
            
            for l, rvl in zip(outs, rv_list):
                cwl["steps"][str(func.__name__)]["run"]["outputs"][l] = {}
                datatype = get_type(rvl)
                label = None                
                if datatype is None:
                    #this failed; its a complex type; for now assign as string
                    datatype = "string"
                    label = str(type(rvl).__name__)                 
                cwl["steps"][str(func.__name__)]["run"]["outputs"][l]["type"] = datatype
                if label is not None:
                    cwl["steps"][str(func.__name__)]["run"]["outputs"][l]["label"] = label
            return returned_value
        
        return wrapper
    return _generate_step
    
def create_cwldict():
    cwl = {}
    cwl["cwlVersion"] = "v1.2"
    cwl["class"] = "Workflow"
    cwl["inputs"] = {}
    cwl["steps"] = {}
    return cwl

def get_type(val):
    typemap = {"str": "string", "bool": "boolean",
              "int": "int", "double": "double", 
              "NoneType": "null", "float": "float",
              "int64": "int", "float64": "float"}
    if type(val).__name__ in typemap.keys():
        val_type = typemap[type(val).__name__]
    elif isinstance(val, (list, tuple)):
        first_val_type = typemap[type(val[0]).__name__]
        val_type = f"{first_val_type}[]"
    elif type(val).__name__ == "ndarray":
        first_val_type = typemap[type(val[0]).__name__]
        val_type = f"{first_val_type}[]"
    else:
        return None
    return val_type

def add_to_inputs(cwl, inputdict):
    for key, val in inputdict.items():
        cwl["inputs"][key] = {}
        cwl["inputs"][key]["type"] = get_type(val)