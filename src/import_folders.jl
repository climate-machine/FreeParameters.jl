#####
##### Import structs with `FreeParameter`s in folder structured format
#####

export import_struct

function import_struct(s::T, directory::S, et::ExportType, ::FolderStructure, _filename::S, stop_recursion_type=FreeParameter) where {S,T,F<:Function}
  return import_struct_folder(s, directory, leaf_filter(et), _filename, stop_recursion_type)
end

"""
    import_struct(s::T, directory::S) where {S,T}

Import struct `s` to directory `directory`
with the same structure as `s`.

 - `stop_recursion_type` stop recursion when reaching type `stop_recursion_type`
"""
function import_struct_folder(s::T,
                              directory::S,
                              is_leaf::F,
                              _filename::S,
                              stop_recursion_type,
                              subdir::S="",
                              fn_parent=nothing) where {S,T,F<:Function}
  subdir = fn_parent==nothing ? string(FreeParameters.strip_type(T)) : joinpath(subdir,string(fn_parent))
  props = getproperty.(Ref(s), fieldnames(T))
  if any(is_leaf.(props)) || any(isa.(props, stop_recursion_type))
    dir_used = joinpath(directory, subdir)
    # mkpath(dir_used)
    params = joinpath(dir_used, _filename)
    open(params, "r") do io
      for fn in fieldnames(T)
        prop = getproperty(s, fn)
        if is_leaf(prop) || prop isa stop_recursion_type
          setproperty!(s, fn, get_val_from_var(strip(last(split(readline(io), "=")), ' ')))
        end
      end
    end
  end

  for fn in fieldnames(T)
    prop = getproperty(s, fn)
    if !isbits(prop) && !is_leaf(prop) && !(prop isa stop_recursion_type)
      import_struct_folder(prop, directory, is_leaf, _filename, stop_recursion_type, subdir, fn)
    end
  end
end