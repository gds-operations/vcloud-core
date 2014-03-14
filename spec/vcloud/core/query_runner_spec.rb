require 'spec_helper'

describe Vcloud::QueryRunner do
  before(:each) do
    @mock_fog_interface = StubFogInterface.new
    Vcloud::Fog::ServiceInterface.stub(:new).and_return(@mock_fog_interface)
    @query_runner = Vcloud::QueryRunner.new()
  end

  it 'should return no results when fog returns no results' do
    @mock_fog_interface.stub(:get_execute_query).and_return({})

    result = @query_runner.run()

    result.should == []
  end

  it 'return no results when fog results do not include a Record' do
    @mock_fog_interface.stub(:get_execute_query).and_return(
        {
            :WibbleBlob => {:field1 => 'Stuff 1'}
        }
    )

    result = @query_runner.run()

    result.size.should == 0 
  end

  it 'should return a single result when fog returns a single result' do
    fields = {:field1 => 'Stuff 1'}
    @mock_fog_interface.stub(:get_execute_query).and_return(
        {
            :WibbleRecord => [fields]
        }
    )

    result = @query_runner.run()

    result.size.should == 1
    result[0].should == fields
  end

  it 'should wrap single result from fog in list' do
    fields = {:field1 => 'Stuff 1'}
    @mock_fog_interface.stub(:get_execute_query).and_return(
        {
            :WibbleRecord => fields
        }
    )

    result = @query_runner.run()

    result.size.should == 1
    result[0].should == fields
  end

  it 'should return all results returned by fog' do
    fields = {:field1 => 'Stuff 1'}
    more_fields = {:field1 => 'More Stuff 1'}
    @mock_fog_interface.stub(:get_execute_query).and_return(
        {
            :WibbleRecord => [fields, more_fields]
        }
    )

    result = @query_runner.run()

    result.size.should == 2
    result[0].should == fields
    result[1].should == more_fields
  end

end

