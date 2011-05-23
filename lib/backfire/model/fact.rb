module Backfire
  module Model

    #  class Fact
    #  Represents a known fact in the rule base
    #  Origin is a reference to the query or rule which established the value for the fact
    #
    #  Nomenclature :

    #  value -- domain value for this fact.  Can be any type
    #  expressions -- list of expressions this factlist appears in ( enables dirty on discovery )
    #  determinants -- list of determinants in which this factlist is the receiver
    #  origin -- rule name, query name, or outside reference which resulted in this fact receiving its most recent value
    #  immutable -- if true, value of this fact cannot be changed once state = true ( value received )
    #  state -- fact is "indeterminate" until value is determined, at which point the state becomes "true"

    class Fact

      include Backfire::Exceptions

      STATE_INDETERMINATE = "indeterminate"
      STATE_TRUE = "true"

      attr_reader :value, :name, :state, :expressions, :determinants
      attr_accessor :origin, :immutable, :factlists

      def initialize( name, value=nil, origin=nil)
        self.name=name
        @value=value
        @origin=origin
        @expressions=[]
        @determinants=[]
        @factlists=[]
        @state=STATE_INDETERMINATE if value.nil?
        @state=STATE_TRUE unless value.nil?
        @immutable = false
      end

      def name=(name)
        raise BackfireException,"Fact name #{name} must be lowercase" if name[0,1] == name[0,1].upcase
        @name=name
      end

      def self.is_list?(name)
        return name[0,1] == name[0,1].upcase
      end

      def self.is_atomic?(name)
        return name[0,1] == name[0,1].downcase
      end

      def is_list?
        return false
      end

      def is_atomic?
        return true
      end

      def add_expression(expr)
        @expressions << expr unless @expressions.include? expr
      end

      def add_determinant(assn)
        @determinants << assn unless @determinants.include? assn
      end

      def value=(val)
        # sets state to true when value is determined
        raise BackfireException, "ERROR : Attempt to change value of immutable fact #{@name} from #{@value} to #{val}" if @immutable
        @value=val
        @state=STATE_TRUE
      end

      def is_indeterminate?
        return @state==STATE_INDETERMINATE
      end

      # propogate dirtyness through dependent expressions and factlists
      def dirty
        expressions.each do |e|
          e.dirty
        end
        factlists.each do |f|
          f.dirty
        end
      end

      def why(workspace, level)
        workspace.facts[self.name.to_sym].determinants.each do |det|
          det.why(workspace,level) unless det.state == Determinant::STATE_INDETERMINATE
        end
      end

      def dump
        output = []
        outstr = "DUMP Fact name :" + "#{@name}".ljust(20)+" value : "+"#{@value}".ljust(30)+
          " origin : "+"#{@origin}".ljust(20)+" state: #{@state}"
        puts outstr
        output << outstr
        return output
      end

    end
  end
end
