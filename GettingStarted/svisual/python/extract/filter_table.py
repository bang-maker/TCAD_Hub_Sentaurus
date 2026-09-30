# Import extraction module 
import svisualpylib.extract as ext

dev_type = ('nMOS nMOS nMOS nMOS nMOS nMOS nMOS nMOS'
            ' pMOS pMOS pMOS pMOS pMOS pMOS pMOS pMOS')
dev_type = dev_type.split()

lgs = ('0.090 0.090 0.045 0.045 0.130 0.130 0.065 0.065' 
       ' 0.065 0.065 0.045 0.045 0.130 0.130 0.090 0.090')
lgs = lgs.split()  

stress = 'no yes no yes no yes no yes no yes no yes no yes no yes'
stress = stress.split()
    
vtgms = ('0.424 0.0374 0.313 0.263 0.414 0.364 0.408 0.358' 
         ' -0.344 -0.294 -0.232 -0.182 x x -0.374 -0.324')
vtgms = vtgms.split()  

# Ex 1: Get Vt roll-off curve for PMOS 
# Filter using one condition
conditions = [{'Target': 'pMOS', 'Values': dev_type}] 
lg, vtgm = ext.filter_table(lgs, vtgms, conditions, ncond=1)
print(f'Filtered lg: {lg}')
print(f'Filtered vtgm: {vtgm}')

#-> Filtered lg: [0.045 0.045 0.065 0.065 0.09  0.09 ]
#-> Filtered vtgm: [-0.232 -0.182 -0.344 -0.294 -0.374 -0.324]

# Ex 2: Plot Vt roll-off curve for PMOS under stress 
# Filter using two conditions
conditions = [
    {'Target': 'pMOS', 'Values': dev_type}, 
    {'Target': 'yes',  'Values': stress}
] 

lg, vtgm = ext.filter_table(lgs, vtgms, conditions, ncond=2)
print(f'Filtered lg: {lg}')
print(f'Filtered vtgm: {vtgm}')

#-> Filtered lg: [0.045 0.065 0.09 ]
#-> Filtered vtgm: [-0.182 -0.294 -0.324]

# Create variables with filtered values
sv.create_variable(dataset='VtgmLg', name='Lg', values=lg)
sv.create_variable(dataset='VtgmLg', name='Vtgm', values=vtgm)

sv.create_plot(name='Plot_VtRollOff', xy=True) 
sv.create_curve(name='VtRollOff', dataset='VtgmLg', axisX='Lg', axisY='Vtgm') 
sv.set_curve_prop(
    'VtRollOff', color='red', 
    label='VtRollOff (pMOS under stress)', 
    line_style='solid', line_width=3, show_markers=True, markers_size=7)

# Annotate plot
sv.set_plot_prop(title='Roll-off Curve', title_font_size=20, show_grid=True)
sv.set_axis_prop(
    axis='x', title='Lg [<greek>m</greek>m]', 
    title_font_size=16, label_font_size=14, type='linear')
sv.set_axis_prop(
    axis='y', title='Vtgm [V]', 
    title_font_size=16, label_font_size=14, type= 'linear')
sv.set_legend_prop(
    label_font_size=12, location='top_right', label_font_att='bold')