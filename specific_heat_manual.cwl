cwlVersion: v1.2
class: Workflow

inputs:
  projectname:
    type: string
  element:
    type: string
  repetitions:
    type: int[]
  temperature:
    type: float
  pressure:
    type: float
  potential:
    type: string
  atomic_mass:
    type: float

steps:
  create_project:
    run:
      class: Operation
      inputs:
        projectname: string
      outputs:
        modprojectname: string
    in:
      projectname: projectname
    out: 
      [modprojectname]
    
  
  create_structure:
    run:
      class: Operation
      inputs:
        projectname: string
        element: string
        repetitions: int[]
      outputs:
        outfile: File
        natoms: int
    in:
      projectname: create_project/modprojectname
      element: element
      repetitions: repetitions
    out:
      [outfile, natoms]
  
  equilibrate_structure:
    run:
      class: Operation
      inputs:
        projectname: string
        structure: File
        temperature: float
        pressure: float
        potential: string
      outputs:
        eq_structure: File
    in:
      projectname: create_project/modprojectname
      structure: create_structure/outfile
      temperature: temperature
      pressure: pressure
      potential: potential
    out:
      [eq_structure]
  
  get_energy_volume:
    run:
      class: Operation
      inputs:
        projectname: string
        structure: File
        temperature: float
        pressure: float
        potential: string
      outputs:
        energy_total: float[]
        volume: float[]
    in:
      projectname: create_project/modprojectname
      structure: equilibrate_structure/eq_structure
      temperature: temperature
      pressure: pressure
      potential: potential
    out:
      [energy_total, volume]
  
  calculate_cp:
    run:
      class: Operation
      inputs:
        energy: float[]
        no_atoms: int
        temperature: float
        atomic_mass: float
      outputs:
        cp: float
    in:
        energy: get_energy_volume/energy_total
        no_atoms: create_structure/natoms
        temperature: temperature
        atomic_mass: atomic_mass
    out:
      [cp]

  calculate_ap:
    run:
      class: Operation
      inputs:
        energy: float[]
        volume: float[]
        temperature: float
      outputs:
        ap: float
    in:
        energy: get_energy_volume/energy_total
        volume: get_energy_volume/volume
        temperature: temperature
    out:
      [ap]

      

outputs:
  cp:
    type: float
    outputSource: calculate_cp/cp 
  ap:
    type: float
    outputSource: calculate_ap/ap 