from distutils.core import Extension, setup
from Cython.Build import cythonize

setup(
        ext_modules = cythonize(Extension(
            'moduleinterface.master',
            sources = ['moduleinterface/_master_cython.pyx'],
            language = 'c++',
            include_dirs = [
                'libraries/ModuleInterface/src',
                'libraries/PJON/src/',
                'libraries/ArduinoJson/src/'
                ],
            define_macros=[('LINUX', 1)]
            ))
        )
'''
setup(
        ext_modules = cythonize(
            'moduleinterface/master/_master_cython.pyx',
            aliases={
                'MI_SRC' : 'libraries/ModuleInterface/src',
                'PJON_SRC' : 'libraries/PJON/src',
                'ARDUINO_JSON_SRC' : 'libraries/ArduinoJson/src'
                },
            compiler_directives={'language_level' : 3})
        )
'''
