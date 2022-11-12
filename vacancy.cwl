cwlVersion: v1.2
class: Workflow


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
            label: "structure"
            type: File
      in:
         element: element
         supercell: supercell
      out: [structure]
         
   minimize_structure:
      run:
         class: Operation
         inputs:
             input_structure: File
             pair_style: string
             pair_coeff: string
         outputs:
             equilibrium_energy: float
             equilibrium_volume: float
             minimized_structure: File
      in:
         input_structure: create_structure/structure
         pair_style: pair_style
         pair_coeff: pair_coeff
      out: [equilibrium_energy, minimized_structure]
   
   delete_atom:
      run:
         class: Operation
         inputs:
            input_structure: File
         outputs:
            output_structure: File
      in:
         input_structure: minimize_structure/minimized_structure
      out:
         [output_structure]
   
   calculate_energy:
      run:
         class: Operation
         inputs:
            input_structure: File
            pair_style: string
            pair_coeff: string
         outputs:
            energy: float
      in:
         input_structure: delete_atom/output_structure
         pair_style: pair_style
         pair_coeff: pair_coeff
      out:
         [energy]
   
   calculate_difference:
      run:
         class: Operation
         inputs:
            energy_of_bulk: float
            energy_of_vacany: float
         outputs:
            energy_difference: float
      in:
         energy_of_bulk: minimize_structure/equilibrium_energy
         energy_of_vacany: calculate_energy/energy
      out:
         [energy_difference]
      
            
outputs:
   out:
      type: float
      outputSource: calculate_difference/energy_difference