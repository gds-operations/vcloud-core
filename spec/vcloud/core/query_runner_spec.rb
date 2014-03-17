require 'spec_helper'

describe Vcloud::QueryRunner do
  before(:each) do
    @mock_fog_interface = StubFogInterface.new
    Vcloud::Fog::ServiceInterface.stub(:new).and_return(@mock_fog_interface)
    @query_runner = Vcloud::QueryRunner.new()
  end

  context '#available_query_types' do
    it 'should return empty array if no data' do
      @mock_fog_interface.stub(:get_execute_query).and_return({:Link => {}})

      result = @query_runner.available_query_types

      result.size.should == 0
    end

    it 'should parse the query types returned' do
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {:Link => [
          {:rel  => 'down',
           :href => 'query?type=alice&#38;format=references'},
        ]})

      result = @query_runner.available_query_types

      result.size.should == 1
      result[0][0].should == 'alice'
      result[0][1].should == 'references'
    end

    it 'should return the set of data' do
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {:Link => [
          {:rel  => 'down',
           :href => 'query?type=alice&#38;format=references'},
          {:rel  => 'down',
           :href => 'query?type=alice&#38;format=references'},
        ]})

      result = @query_runner.available_query_types

      result.size.should == 2
    end
  end

  context '#run' do
    it 'should return no results when fog returns no results' do
      @mock_fog_interface.stub(:get_execute_query).and_return({})

      result = @query_runner.run()

      result.should == []
    end

    it 'return no results when fog results do not include a "Record" or a "Reference"' do
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {
          :WibbleBlob => {:field1 => 'Stuff 1'}
        }
      )

      result = @query_runner.run()

      result.size.should == 0
    end

    it 'should return a single result when fog returns a single record' do
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

    it 'should return a single result when fog returns a single reference' do
      fields = {:field1 => 'Stuff 1'}
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {
          :WibbleReference => [fields]
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

    it 'should return all results in a record returned by fog' do
      fields      = {:field1 => 'Stuff 1'}
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

    it 'should return the first item if more than one records provided' do
      fields1 = {:field1 => 'Stuff 1'}
      fields2 = {:field1 => 'Stuff 2'}
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {
          :WibbleRecord => [fields1],
          :WobbleRecord => [fields2]
        }
      )

      result = @query_runner.run()

      result.size.should == 1
      result[0].should == fields1
    end

    it 'should raise error if lastPage is not an integer' do
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {
          :lastPage     => :qwerty,
          :WibbleRecord => []
        }
      )

      expect { @query_runner.run() }.to raise_error('Invalid lastPage (qwerty) in query results')
    end

    it 'should get each page and collect the results' do
      fields = {:field1 => 'Stuff 1'}
      @mock_fog_interface.stub(:get_execute_query).and_return(
        {
          :lastPage     => 2,
          :WibbleRecord => [fields]
        }

      )
      result = @query_runner.run()

      result.size.should == 2
      result[0].should == fields
      result[1].should == fields
    end
  end
end

