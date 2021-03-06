module Backfire
  module Model
    class FactList < Fact

      include Backfire::Exceptions

      #
      # FactList is a collection of facts which serves as a proxy that applies all its members
      # wherever the FactList is referenced.  In use it is similar to a Fact and is implemented
      # as a subclass of Fact
      #
      # FactLists are currently distinguished in expressions, etc by name starting with an uppercase letter
      #
      # Nomenclature :
      #
      #  expressions -- list of expressions this factlist appears in ( enables dirty on discovery )
      #  determinants -- list of determinants in which this factlist is the receiver
      #

      attr_reader :members
      def initialize (name, values=[], origin=nil, workspace=nil)
        @members=[]
        super(name, nil, origin, workspace)
        @state=STATE_INDETERMINATE
        @child_seq=0 # for generating fact names dynamically where necessary
        add_member(*values) unless values.nil? || values.empty?
      end

      def name=(name)
        raise BackfireException,"FactList name #{name} must start with uppercase character." if name[0,1] == name[0,1].downcase
        @name=name
      end

      def is_list?
        return true
      end

      def is_atomic?
        return false
      end

      def fact_values
        vals=[]
        members.each {|member| vals << member.value}
        vals
      end

      def add_member(*facts)
        return if facts.empty?
        first, *rest = facts
#        raise BackfireException, "ERROR: Attempt to add non-fact #{first} class #{first.class.name} to FactList #{@name}" unless first.instance_of? Fact
        unless @members.include?(first) || (first.instance_of?(Fact) && self.fact_values.include?(first.value)) || self.fact_values.include?(first)
#          puts "[FactList] Adding member #{first.inspect} to values #{self.values.inspect}"
          newfact = first.instance_of?(Fact) ? first : Fact.new(nil, first, self.name, self.workspace)
          @members << newfact
          newfact.factlists << self
        end
        @state = STATE_TRUE
        add_member(*rest)
        dirty
      end

      # propogate dirtyness through dependent expressions
      def dirty
        @expressions.each do |e|
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