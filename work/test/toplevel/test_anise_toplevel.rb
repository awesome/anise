require 'anise'

include Anise

class Test_Anise_Toplevel_Annotation_0 < Test::Unit::TestCase
  class X
    attr :a

    ann :@a, :valid => lambda{ |x| x.is_a?(Integer) }

    ann :a, :class => Integer

    def initialize(a)
      @a = a
    end

    def validate
      instance_variables.each do |iv|
        if validator = self.class.ann(iv)[:valid]
          value = instance_variable_get(iv)
          unless validator.call(value)
            raise "Invalid value #{value} for #{iv}"
          end
        end
      end
    end
  end

  def test_annotation_class
    assert_equal(Integer, X.ann(:a, :class))
  end

  def test_annotation_validate
    x = X.new(1)
    assert_nothing_raised{ x.validate }
  end
end

class Test_Anise_Toplevel_Annotation_1 < Test::Unit::TestCase
  class X
    def x1 ; end
    ann :x1, :a=>1
    ann :x1, :b=>2
  end

  def test_1_01
    assert_equal( X.ann(:x1,:a), X.ann(:x1,:a) )
    assert_equal( X.ann(:x1,:a).object_id, X.ann(:x1,:a).object_id )
  end
  def test_1_02
    X.ann :x1, :a => 2
    assert_equal( 2, X.ann(:x1,:a) )
  end
end

class Test_Anise_Toplevel_Annotation_2 < Test::Unit::TestCase
  class X
    def x1 ; end
    ann :x1, :a=>1
    ann :x1, :b=>2
  end
  class Y < X ; end

  def test_2_01
    assert_equal( Y.ann(:x1,:a), Y.ann(:x1,:a) )
    assert_equal( Y.ann(:x1,:a).object_id, Y.ann(:x1,:a).object_id )
  end
  def test_2_02
    assert_equal( 1, Y.ann(:x1,:a) )
    assert_equal( 2, Y.ann(:x1,:b) )
  end
  def test_2_03
    Y.ann :x1,:a => 2
    assert_equal( 2, Y.ann(:x1,:a) )
    assert_equal( 2, Y.ann(:x1,:b) )
  end
end

class Test_Anise_Toplevel_Annotation_3 < Test::Unit::TestCase
  class X
    ann :foo, Integer
  end
  class Y < X
    ann :foo, String
  end

  def test_3_01
    assert_equal( Integer, X.ann(:foo, :class) )
  end
  def test_3_02
    assert_equal( String, Y.ann(:foo, :class) )
  end
end

class Test_Anise_Toplevel_Annotation_4 < Test::Unit::TestCase
  class X
    ann :foo, :doc => "hello"
    ann :foo, :bar => []
  end
  class Y < X
    ann :foo, :class => String, :doc => "bye"
  end

  def test_4_01
    assert_equal( "hello", X.ann(:foo,:doc) )
  end
  def test_4_02
    assert_equal( X.ann(:foo), { :doc => "hello", :bar => [] } )
  end
  def test_4_03
    X.ann(:foo,:bar) << "1"
    assert_equal( ["1"], X.ann(:foo,:bar) )
  end
  def test_4_04
    assert_equal( "bye", Y.ann(:foo,:doc) )
  end
  def test_4_05
    #assert_equal( nil, Y.ann(:foo,:bar) )
    assert_equal( ["1"], Y.ann(:foo,:bar) )
  end
  def test_4_06
    Y.ann(:foo, :doc => "cap")
    assert_equal( "cap", Y.ann(:foo, :doc)  )
  end
  def test_4_07
    Y.ann!(:foo,:bar) << "2"
    assert_equal( ["1", "2"], Y.ann(:foo,:bar) )
    assert_equal( ["1", "2"], Y.ann(:foo,:bar) )
    assert_equal( ["1"], X.ann(:foo,:bar) )
  end
end

class Test_Anise_Toplevel_Annotator < Test::Unit::TestCase
  class X
    annotator :req

    req 'r'
    def a ; "a"; end

    req 's', 't'
    attr :b

    def initialize
      @b = "b"
    end
  end

  def test_normal
    x = X.new
    assert_equal("a", x.a)
    assert_equal("b", x.b)
  end

  def test_annotated_a
    assert_equal( {:req=>'r'}, X.ann(:a) )
  end

  def test_annotated_b
    assert_equal( {:req=>['s', 't']}, X.ann(:b) )
  end
end

class Test_Anise_Toplevel_Attribute < Test::Unit::TestCase
  class X
    attr :q
    attr :a, :x => 1
  end

  def test_attr_a
    assert_equal( {:x=>1}, X.ann(:a) )
  end
end

class Test_Anise_Toplevel_Attribute_Using_Attr < Test::Unit::TestCase
  class A
    attr :x, :cast=>"to_s"
  end

  def test_01
    assert_equal( "to_s", A.ann(:x,:cast) )
  end
end

class Test_Anise_Toplevel_Attribute_Using_Attr_Accessor < Test::Unit::TestCase
  class A
    attr_accessor :x, :cast=>"to_s"
  end

  def test_instance_attributes
    a = A.new
    assert_equal( [:x], A.instance_attributes - [:taguri] )
  end
end

