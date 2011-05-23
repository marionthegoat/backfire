module Backfire
  module Model
    class FactList

      include Backfire::Exceptions
 
      # Nomenclature :
      #
      #  expressions -- list of expressions this factlist appears in ( enables dirty on discovery )
      #  determinants -- list of determinants in which this factlist is the receiver
      #
      STATE_INDETERMINATE = "indeterminate"
      STATE_TRUE = "true"
      attr_reader :name, :members
      attr_accessor :expressions, :determinants, :state
      def initialize (name)
        self.name=name
        @expressions=[]
        @members=[]
        @determinants=[]
        @state=STATE_INDETERMINATE
      end

      def name=(name)
        raise BackfireException,"Factlist name #{name} must start with uppercase character." if name[0,1] == name[0,1].downcase
        @name=name
      end
      def is_list?
        return true
      end

      def is_atomic?
        return false
      end

      def add_determinant(det)
        @determinants << det unless @determinants.include? det
      end

      def add_expression(expr)
        raise BackfireException,"[FactList.add_expression] Error : cannot add #{expr} as expression, does not respond to dirty." unless expr.respond_to? "dirty"
        @expressions << expr unless @expressions.include? expr
      end

      def add_member(*facts)
        return if facts.empty?
        first, *rest = facts
        raise BackfireException, "ERROR: Attempt to add non-fact #{first} class #{first.class.name} to FactList #{@name}" unless first.instance_of? Fact
        unless @members.include?(first)
          @members << first
          first.factlists << self
        end
        @state = STATE_TRUE
        add_member(*rest)
        dirty
      end

      # propogate dirtyness through dependent expressions
      def dirty
        expressions.each do |e|
          e.dirty
        end
      end

      def dump
        output = []
        fstr = ""
        @members.each{ |f| fstr+=(" "+f.name)}
        outstr = "DUMP FactList name :" + "#{@name}".ljust(20)+" members : "+"#{fstr}"
        puts outstr
        output << outstr
        return output
      end

    end
  end
end