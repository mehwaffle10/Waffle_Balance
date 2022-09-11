
import os

if __name__ == '__main__':
    mapmakers = {}
    directory = os.getcwd()
    for filename in os.listdir(directory):
        path = os.path.join(directory, filename)

        # Only add maps
        if os.path.isfile(path) and filename.endswith('.png'):
            # Get the name of the mapmaker
            parts = filename.split('_')
            mapmaker = parts[0] if len(parts) > 1 else 'unknown'

            # Add the map to the mapmakers list
            if mapmaker not in mapmakers:
                mapmakers[mapmaker] = []
            mapmakers[mapmaker].append(filename + ';')

    output = '# KAG mapcycle;\n# maps for capture the flag\n\nmapcycle ='

    for mapmaker in mapmakers:
        output += f'\n# {mapmaker}' + '\nMaps/'.join([''] + mapmakers[mapmaker])

    with open(os.path.join(directory, '..', 'Rules', 'CTF', 'mapcycle.cfg'), 'w') as config:
        config.write(output)
