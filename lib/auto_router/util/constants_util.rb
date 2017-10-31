module AutoRouter::Util
  class ConstantsUtil
    def self.module_tree(classes)
      clazzez = Array.wrap(classes)

      result = {classes: [], submodules: {}}
      clazzez.each do |clz|
        clz_name = clz.to_s.constantize
        module_str = clz.to_s.deconstantize

        cur = result
        modules = module_str.split('::')
        modules.each_with_index {|mod_name, i|
          mod_data = cur[:classes][mod_name] ||= {classes: [], submodules: {}}
          last = i == modules.count - 1
          if last
            mod_data[:classes] << clz
          else
            cur = mod_data
          end
        }
      end
      return result
    end
  end #class
end #module