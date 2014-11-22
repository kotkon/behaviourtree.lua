local BehaviourTree = require 'lib/behaviour_tree'
local InvertDecorator = BehaviourTree.InvertDecorator

describe('InvertDecorator', function()
  local subject
  before_each(function()
    subject = InvertDecorator:new()
  end)

  describe(':initialize', function()
    it('should copy any attributes to the node', function()
      local node = InvertDecorator:new({testfield = 'foobar'})
      assert.is_equal(node.testfield, 'foobar')
    end)
    it('should register the node if the name is set', function()
      local node = InvertDecorator:new({name = 'foobar'})
      assert.is_equal(BehaviourTree.getNode('foobar'), node)
    end)
    it('should get the node from the registry', function()
      local s = spy.on(BehaviourTree.Registry, 'getNode')
      InvertDecorator:new({node = 'foobar'})
      assert.spy(s).was.called_with('foobar')
      BehaviourTree.Registry.getNode:revert()
    end)
  end)

  describe(':setNode', function()
    it('should set the node', function()
      local task = BehaviourTree.Task:new()
      subject:setNode(task)
      assert.is_equal(subject.node,task)
    end)
    it('should get the node from the registry', function()
      local s = spy.on(BehaviourTree.Registry, 'getNode')
      subject:setNode('foobar')
      assert.spy(s).was.called_with('foobar')
      BehaviourTree.Registry.getNode:revert()
    end)
  end)

  describe(':start', function()
    local task
    before_each(function()
      task = BehaviourTree.Task:new()
      subject:setNode(task)
    end)
    it('should call start on the node', function()
      stub(task, 'start')
      subject:start('foobar')
      assert.stub(task.start).was.called_with(task, 'foobar')
    end)
  end)

  describe(':finish', function()
    local task
    before_each(function()
      task = BehaviourTree.Task:new()
      subject:setNode(task)
    end)
    it('should call finish on the node', function()
      stub(task, 'finish')
      subject:finish('foobar')
      assert.stub(task.finish).was.called_with(task, 'foobar')
    end)
  end)

  describe(':run', function()
    local task
    before_each(function()
      task = BehaviourTree.Task:new()
      subject:setNode(task)
    end)
    it('should set control on the node', function()
      stub(task, 'setControl')
      subject:run('foobar')
      assert.stub(task.setControl).was.called_with(task, subject)
    end)
    it('should call run on the node', function()
      stub(task, 'run')
      subject:run('foobar')
      assert.stub(task.run).was.called_with(task, 'foobar')
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

  describe(':running', function()
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
  end)

  describe(':success', function()
    it('should call fail on the control', function()
      subject.control = {}
      stub(subject.control, 'fail')
      subject:success()
      assert.stub(subject.control.fail).was.called()
    end)
  end)

  describe(':fail', function()
    it('should call success on the control if control defined', function()
      subject.control = {}
      stub(subject.control, 'success')
      subject:fail()
      assert.stub(subject.control.success).was.called()
    end)
  end)
end)

