module Backfire
  module Model

    #  class Fact
    #  Represents a known fact in the rule base
    #  Origin is a reference to the query or rule which established the value for the fact
    #
    #  Facts are currently distinguised from FactLists in expressions, etc. by name starting with lowercase letter.
    #
    #  Nomenclature :

    #  value -- domain value for this fact.  Can be any type
    #  expressions -- list of expressions this factlist appears in ( enables dirty on discovery )
    #  determinants -- list of determinants in which this factlist is the receiver
    #  origin -- rule name, query name, or outside reference which resulted in this fact receiving its most recent value
    #  immutable -- if true, value of this fact cannot be changed once state = true ( value received )
    #  state -- fact is "indeterminate" until value is determined, at which point the state becomes "true"

    class Fact

      STATE_TRUE = "true"
      STATE_INDETERMINATE = "indeterminate"

      include Backfire::Exceptions

      attr_reader :value, :name, :state, :expressions, :determinants
      attr_accessor :origin, :immutable, :factlists, :workspace

# @param [String] name
# @param [Object] value
# @param [String] origin

      def initialize(name, value=nil, origin=nil, workspace=nil)
        @workspace = workspace
        self.name=name
        @value=value
        @origin=origin
        @expressions=[]
        @determinants=[]
        @factlists=[]
        @state=value.nil? ? STATE_INDETERMINATE : STATE_TRUE
        @immutable = false
        @workspace = workspace
        @workspace.add_fact(self) unless @workspace.nil?
      end

      def name=(name)
        @name=name
        @name=workspace.gen_dynamic_fact_name if @name.nil? unless workspace.nil?
        raise BackfireException, "Fact name is nil and no workspace has been provided to generate dynamic name." if @name.nil?
        raise BackfireException,"Fact name #{@name} must be lowercase" if @name[0,1] == @name[0,1].upcase
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

      def value=(val)
        # sets state to true when value is determined
        raise BackfireException, "ERROR : Attempt to change value of immutable fact #{@name} from #{@value} to #{val}" if @immutable
        @value=val
        @state=STATE_TRUE
      end

      def is_indeterminate?
        return @state==STATE_INDETERMINATE
      end

      def is_true?
        return @state==STATE_TRUE
      end

      # @param [Determinant] det
      def add_determinant(det)
 #       puts "adding determinant #{det.name} for #{@name} #{self}"
        @determinants << det unless @determinants.include? det
        det.fact = self unless det.fact
 #       puts "determinants.size = #{@determinants.size}"
      end

      def add_expression(expr)
        raise BackfireException,"[Fact.add_expression] Error : cannot add #{expr} as expression, does not respond to dirty." unless expr.respond_to? "dirty"
        @expressions << expr unless @expressions.include? expr
      end

      # propogate dirtyness through dependent expressions and factlists
      def dirty
        @expressions.each do |e|
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
