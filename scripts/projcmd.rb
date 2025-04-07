#!/usr/bin/env ruby
# frozen_string_literal: true

# projcmd.rb - Xcode Project Command Line Tool
#
# This script provides command-line utilities for manipulating Xcode project files.
# It uses the xcodeproj gem to programmatically interact with .xcodeproj files.
#
# Usage:
#   ruby projcmd.rb [options] link|unlink <path-to-framework>
#
# Commands:
#   link: link a framework to the project
#   unlink: unlink a framework from the project
#
# Options:
#   --help, -h    Show this help message
#   --proj <path-to-xcodeproj> path to the xcodeproj file
#   --embeddable, -E   switch indicate that the specified framework is embeddable
#   --static, -s   switch indicate that the specified framework is static
#   --target <target-name> name of the target to link the framework to
#   --parent <parent-name> name of the parent to link the framework to
#
# Examples:
#   ruby projcmd.rb --help
#   ruby projcmd.rb --proj /path/to/project.xcodeproj -E link /path/to/framework
#   ruby projcmd.rb --proj /path/to/project.xcodeproj -s link /path/to/framework
#   ruby projcmd.rb --proj /path/to/project.xcodeproj unlink /path/to/framework
#
# Author: Mark Adamcin
# Version: 1.0.0
# License: MIT

require 'xcodeproj'
require 'optparse'

def parse_options
  options = {
    project_path: nil,
    embeddable: false,
    static: false,
    target: nil,
    parent: nil
  }

  OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options] link|unlink <path-to-framework>"

    opts.on("--proj PATH", "Path to the xcodeproj file") do |path|
      options[:project_path] = path
    end

    opts.on("-E", "--embeddable", "Framework is embeddable") do
      options[:embeddable] = true
    end

    opts.on("-s", "--static", "Framework is static") do
      options[:static] = true
    end

    opts.on("--target NAME", "Target name") do |name|
      options[:target] = name
    end

    opts.on("--parent NAME", "Parent name") do |name|
      options[:parent] = name
    end

    opts.on("-h", "--help", "Show this help message") do
      puts opts
      exit
    end
  end.parse!

  options
end

def link_framework(project, framework_path, options)
  # Implementation for linking a framework
  puts "Linking framework: #{framework_path}"
  # TODO: Implement framework linking logic
end

def unlink_framework(project, framework_path, options)
  # Implementation for unlinking a framework
  puts "Unlinking framework: #{framework_path}"
  # TODO: Implement framework unlinking logic
end

def main
  options = parse_options
  command = ARGV.shift
  framework_path = ARGV.shift

  unless command && framework_path
    puts "Error: Missing command or framework path"
    exit 1
  end

  unless options[:project_path]
    puts "Error: Project path is required"
    exit 1
  end

  begin
    project = Xcodeproj::Project.open(options[:project_path])
    
    case command
    when 'link'
      link_framework(project, framework_path, options)
    when 'unlink'
      unlink_framework(project, framework_path, options)
    else
      puts "Error: Unknown command '#{command}'"
      exit 1
    end

    project.save
  rescue => e
    puts "Error: #{e.message}"
    exit 1
  end
end

main
