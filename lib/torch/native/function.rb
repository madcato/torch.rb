module Torch
  module Native
    class Function
      attr_reader :function

      def initialize(function)
        @function = function
      end

      def func
        @func ||= @function["func"]
      end

      def name
        @name ||= func.split("(", 2).first
      end

      def python_module
        @python_module ||= @function["python_module"]
      end

      def variants
        @variants ||= (@function["variants"] || "function").split(", ")
      end

      def args
        @args ||= begin
          args = []
          pos = true
          args_str = func.split("(", 2).last.split(") ->").first
          args_str.split(", ").each do |a|
            if a == "*"
              pos = false
              next
            end
            t, _, k = a.rpartition(" ")
            k, d = k.split("=")
            has_default = !d.nil?
            d = d.to_i if d.to_i.to_s == d
            d = true if d == "True"
            d = false if d == "False"
            d = nil if d == "None"

            next if t == "Generator?"
            args << {name: k, type: t, default: d, pos: pos, has_default: has_default}
          end
          args
        end
      end

      def out_size
        @out_size ||= func.split("->").last.count("!")
      end

      def ret_size
        @ret_size ||= func.split("->").last.split(", ").size
      end

      def out?
        out_size > 0 && base_name[-1] != "_"
      end

      def ruby_name
        @ruby_name ||= begin
          name = base_name
          if name.end_with?("_")
            "#{name[0..-2]}!"
          elsif name.start_with?("is_")
            "#{name[3..-1]}?"
          else
            name
          end
        end
      end

      def cpp_name
        @cpp_name ||= "_" + name.downcase.sub(".", "_")
      end

      def base_name
        @base_name ||= name.split(".").first
      end
    end
  end
end
