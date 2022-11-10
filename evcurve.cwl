cwlVersion: v1.2
class: Workflow

requirements:
   ScatterFeatureRequirement: {}
 
inputs:
   element:
      type: string
   pair_style:
      type: string
   pair_coeff:
      type: string
   supercell:
      type: int[]

steps:
   create_structure:
      run:
        class: Operation
        inputs:
             element: string
             supercell: int[]
        outputs:
          structure:
            type: File
      in:
         element: element
         supercell: supercell
      out: [structure]
         
   calculate_lattice_constant:
      run:
         class: Operation
         inputs:
             input_structure: File
             pair_style: string
             pair_coeff: string
         outputs:
             equilibrium_energy: float
             lattice_constant: float
      in:
         input_structure: create_structure/structure
         pair_style: pair_style
         pair_coeff: pair_coeff
      out: [lattice_constant]
      
   create_lattice_array:
      run:
         class: Operation
         inputs:
            lattice_constant: float
            number_of_calculations:
               type: int
               default: 10
         outputs:
            lattice_array: float[]
      in:
         lattice_constant: calculate_lattice_constant/lattice_constant
      out:
         [lattice_array]
   
   calculate_energy:
      scatter: lattice
      run:
        class: Operation
        inputs:
            lattice: float
            pair_style: string
            pair_coeff: string
        outputs:
            energy: float
      in:
        lattice: create_lattice_array/lattice_array
        pair_style: pair_style
        pair_coeff: pair_coeff
      out: [energy]
            
outputs:
   out:
      type: float[]
      outputSource: create_lattice_array/lattice_array