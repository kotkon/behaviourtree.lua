require 'spec/custom_asserts'
local BehaviourTree = require 'lib/behaviour_tree'

describe('BehaviourTree', function()
  local subject
  before_each(function()
    subject = BehaviourTree:new({tree = BehaviourTree.Task:new()})
  end)

  describe(':initialize', function()
    it('should copy any attributes to the node', function()
      local node = BehaviourTree:new({testfield = 'foobar'})
      assert.is_equal(node.testfield, 'foobar')
    end)
    it('should register the node if the name is set', function()
      local node = BehaviourTree:new({name = 'foobar'})
      assert.is_equal(BehaviourTree.getNode('foobar'), node)
    end)
  end)

  describe(':start', function()
    it('has a start method', function()
      assert.is_function(subject.start)
    end)
  end)

  describe(':finish', function()
    it('has a finish method', function()
      assert.is_function(subject.finish)
    end)
  end)

  describe(':setObject', function()
    it('should set the object on the node', function()
      subject:setObject('foobar')
      assert.is_equal(subject.object, 'foobar')
    end)
  end)

  describe(':setControl', function()
    it('should set the controller on the node', function()
      subject:setControl('foobar')
      assert.is_equal(subject.control, 'foobar')
    end)
  end)

  describe(':run', function()
    describe('if already started', function()
      before_each(function()
        subject.started = true
      end)
      it('should call running on the control if control defined', function()
        subject.control = {}
        stub(subject.control, 'running')
        subject:run()
        assert.stub(subject.control.running).was.called()
      end)
      it('should do nothing if has no control', function()
        -- testing no error here
        subject:run()
      end)
    end)
    describe('if not running', function()
      it('should set started to true', function()
        assert.is_equal(subject.started, nil)
        subject:run()
        assert.is_true(subject.started)
      end)
      it('should set the object if provided',function()
        subject.object = 'bar'
        subject:run('foo')
        assert.is_equal(subject.object, 'foo')
      end)
      it('should not override the object if none passed in', function()
        subject.object = 'bar'
        subject:run()
        assert.is_equal(subject.object, 'bar')
      end)
      it('should set the root node', function()
        subject:run()
        assert.is_equal(subject.rootNode, subject.tree)
      end)
      it('should look up the tree node', function()
        local s = spy.on(BehaviourTree.Registry, 'getNode')
        subject:run()
        assert.spy(s).was.called()
        BehaviourTree.Registry.getNode:revert()
      end)
      it('should set control on the current node', function()
        stub(subject.tree, 'setControl')
        subject:run()
        assert.stub(subject.tree.setControl).was.called()
      end)
      it('should call start on the current node', function()
        stub(subject.tree, 'start')
        subject:run()
        assert.stub(subject.tree.start).was.called()
      end)
      it('should call run on the current node', function()
        subject.rootNode = subject.tree
        stub(subject.rootNode, 'run')
        subject:run()
        assert.stub(subject.rootNode.run).was.called()
      end)
    end)
  end)

  describe(':running', function()
    before_each(function()
      subject:run()
    end)
    it('should call running on the control if control defined', function()
      subject.control = {}
      stub(subject.control, 'running')
      subject:running()
      assert.stub(subject.control.running).was.called()
    end)
    it('should do nothing if has no control', function()
      -- testing no error here
      subject:running()
    end)
    it('should set started as false', function()
      assert.is_true(subject.started)
      subject:running()
      assert.is_false(subject.started)
    end)
  end)

  describe(':success', function()
    before_each(function()
      subject:run()
    end)
    it('should call success on the control if control defined', function()
      subject.control = {}
      stub(subject.control, 'success')
      subject:success()
      assert.stub(subject.control.success).was.called()
    end)
    it('should do nothing if has no control', function()
      subject:success()
    end)
    it('should call finish on root node', function()
      stub(subject.rootNode, 'finish')
      subject:success()
      assert.stub(subject.rootNode.finish).was.called()
    end)
    it('should set started as false', function()
      assert.is_true(subject.started)
      subject:success()
      assert.is_false(subject.started)
    end)
  end)

  describe(':fail', function()
    before_each(function()
      subject:run()
    end)
    it('should call fail on the control if control defined', function()
      subject.control = {}
      stub(subject.control, 'fail')
      subject:fail()
      assert.stub(subject.control.fail).was.called()
    end)
    it('should do nothing if has no control', function()
      subject:fail()
    end)
    it('should call finish on root node', function()
      stub(subject.rootNode, 'finish')
      subject:fail()
      assert.stub(subject.rootNode.finish).was.called()
    end)
    it('should set started as false', function()
      assert.is_true(subject.started)
      subject:fail()
      assert.is_false(subject.started)
    end)
  end)
end)

