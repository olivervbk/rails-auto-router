class AutoRouter::Util::ConstantsUtil
  def self.module_tree(classes)
    clazzez = Array.wrap(classes)
    clazzez.each do |clz|
      clz_name = clz.to_s.constantize
      modules = clz.to_s.deconstantize

    end
  end
end