# Import Extraction module
import svisualpylib.extract as ext

sv.load_file('DATA/IdVgLin_nMOS_des.plt', name='DC')
vgs = sv.get_variable_data(dataset='DC', varname='gate OuterVoltage')
ids = sv.get_variable_data(dataset='DC', varname='drain TotalCurrent')

# Find maxima
idmax = ext.extract_extremum(ids, 'max', name='IdLin')