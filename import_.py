import importlib.util
import importlib.machinery

def importSourceFile(filepath, modulename=None) :
  # to import Python code from a file, use the native import <basename> statement
  # omit the .py|.pyc|.pyd|.so extension from the filename
  # below imports a file lacking the standard extension and
  # not supported by the native import keyword !!

  ## https://share.google/aimode/PvzgcMy3kTtL5rHNt
  modName = 'customModule_' + "".join(
    ## https://share.google/aimode/ctsfi8IgtugMjLySP
    c if c.isalnum() else "_" for c in filepath
  ).replace(
    "__", "_"
  ) if (modulename is None) else modulename
  #print(modName)

  spec = importlib.util.spec_from_loader(modName, importlib.machinery.SourceFileLoader(modName, filepath)) ## must explicitly assign the loader for file without the proper extension !!
  #spec = importlib.util.spec_from_file_location(modName, filepath) ## only valid for file with the proper extension !! otherwise, will fail silently and returned None !!
  module = importlib.util.module_from_spec(spec)
  spec.loader.exec_module(module)
  #sys.modules[modName] = module ## Optional: Register it in sys.modules so standard imports find it later
  return module

  ## this older load_module() approach is deprecated
  return importlib.machinery.SourceFileLoader(
    modName, filepath
  ).load_module()

  ## exec(open(filepath).read()) ## execfile()
  # below will simply execute the raw source codes
  try :
    with open(filepath, "r") as f: src=f.read()
    exec(src)
  except Exception as e:
    print("Error in [" + filepath + "] => " + str(e))
  #
# importSourceFile
